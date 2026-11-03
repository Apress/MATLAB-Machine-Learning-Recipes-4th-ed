clear; clc; close all;
% Input video
videoFile = fullfile("object_sequence_video","obj.mov");
v = VideoReader(videoFile);
% Extracting image frames from video every 1.5 seconds
samplePeriod = 1.5;
numImages = max(1,floor(v.Duration/samplePeriod));
imgFiles = [];
% Input camera intrinsics
S=load(fullfile("cameraParams.mat"));
intrinsics=S.cameraParams.Intrinsics;
% Image processing
% (1) Resize to match camera calibration size
% (2) Undistort images (removes lens distortion) -> grayscale conversion is for SURF compatibility
v.CurrentTime = 0;
I=readFrame(v); imgSize=[size(I,1) size(I,2)]; calibSize=intrinsics.ImageSize;
needResize=any(imgSize~=calibSize);
rgbUndist=cell(1,numImages); grayUndist=cell(1,numImages);
for i=1:numImages
    v.CurrentTime = (i-1)*samplePeriod;
    if v.CurrentTime >= v.Duration
        numImages = i-1;
        rgbUndist = rgbUndist(1:numImages);
        grayUndist = grayUndist(1:numImages);
        break
    end
    I=readFrame(v);
    if needResize, I=imresize(I,[calibSize(1) calibSize(2)]); end
    Iu=undistortImage(I,intrinsics,"OutputView","same"); 
    rgbUndist{i}=Iu; grayUndist{i}=im2gray(Iu); 
end


% Parameters
maxNumTrialsE=12000; minInliers=50;
border=30; roi=[border border size(grayUndist{1},2)-2*border size(grayUndist{1},1)-2*border];
% Setup view set once 
vSet = imageviewset; validViewIds = [];
for i = 1:numImages
    % Detect features for view i
    points = detectSURFFeatures(grayUndist{i}, ...
        "NumOctaves",8,"MetricThreshold",300,"ROI",roi);
    features = extractFeatures(grayUndist{i}, points, "Upright", true);
    if i == 1
        % First view: initialize view set (no matching yet)
        vSet = addView(vSet, i, rigidtform3d, "Points", points);
        prevPoints = points;
        prevFeatures = features;
        validViewIds(end+1) = i;
        continue
    end
    % Match features to previous accepted view
    indexPairs = matchFeatures(prevFeatures, features, ...
        "MaxRatio",0.7,"Unique",true,"MatchThreshold",40);
    % Estimate relative pose 
    [relPose,inlierIdx] = helperEstimateRelativePose( ...
        prevPoints(indexPairs(:,1)), points(indexPairs(:,2)), ...
        intrinsics, maxNumTrialsE);
    numInliers = nnz(inlierIdx);
    if numInliers < minInliers
        fprintf("View %d/%d: inliers=%d < %d -> skipping view\n", ...
            i,numImages,numInliers,minInliers);
        continue
    end
    % Compose absolute pose for this view from previous valid view
    prevId = validViewIds(end);
    currAbsPose = rigidtform3d(poses(vSet,prevId).AbsolutePose.A * relPose.A);
    % Add view + connection 
    vSet = addView(vSet, i, currAbsPose, "Points", points);
    vSet = addConnection(vSet, prevId, i, relPose, "Matches", indexPairs(inlierIdx,:));
    % Re-triangulate + refine 
    tracks = findTracks(vSet);
    camPoses = poses(vSet);
    xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);
    [xyzPoints,camPoses] = bundleAdjustment(xyzPoints,tracks,camPoses,intrinsics, ...
        "FixedViewId",1,"PointsUndistorted",true,"MaxIterations",80, ...
        "AbsoluteTolerance",1e-7,"RelativeTolerance",1e-15);
    % Store
    vSet = updateView(vSet, camPoses);
    % Update "previous" only if this view was accepted
    prevPoints = points;
    prevFeatures = features;
    validViewIds(end+1) = i;

    fprintf("View %d/%d: inlierMatches=%d, tracks=%d\n", ...
        i,numImages,numInliers,numel(tracks));
end
% Final triangulation + refinement + standard reprojection filter
tracks = findTracks(vSet); 
camPoses = poses(vSet); 
xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);

[xyzPoints,camPoses,reprojectionErrors] = bundleAdjustment(xyzPoints,tracks,camPoses,intrinsics, ...
    "FixedViewId",1,"PointsUndistorted",true,"MaxIterations",200, ...
    "AbsoluteTolerance",1e-7,"RelativeTolerance",1e-15);

goodIdx = reprojectionErrors < 5;
xyzGood = xyzPoints(goodIdx,:);
tracksGood = tracks(goodIdx);

fprintf("FINAL: tracks=%d, kept=%d (reproj<%.1f)\n", numel(tracks), size(xyzGood,1), 5);

% Colorize + plot (same color as reconstructed pixels)
n = numel(tracksGood);
colors = zeros(numel(tracksGood),3,'uint8');
for k = 1:numel(tracksGood)
    I = rgbUndist{tracksGood(k).ViewIds(1)};
    p = round(tracksGood(k).Points(1,:));
    colors(k,:) = I(p(2), p(1), :);
end
ptCloud = pointCloud(xyzGood, "Color", colors);

lo = prctile(xyzGood, 1);
hi = prctile(xyzGood, 99);
pad = 0.08 * (hi - lo); % Add padding (around 8% of object's width)
xl = [lo(1)-pad(1), hi(1)+pad(1)];
yl = [lo(2)-pad(2), hi(2)+pad(2)];
zl = [lo(3)-pad(3), hi(3)+pad(3)];

figure; plotCamera(camPoses,"Size",0.15); hold on; grid on
pcshow(ptCloud,"VerticalAxis","y","VerticalAxisDir","down","MarkerSize",45);
title("Dense SURF-based reconstruction");
xlabel("X"); ylabel("Y"); zlabel("Z");
xlim(xl); ylim(yl); zlim(zl);
camorbit(0,-25); hold off
