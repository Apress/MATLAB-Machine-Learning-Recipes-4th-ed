% Load trained detector (Faster R-CNN)
detector = load(fullfile(dstDir,'blob_frcnn.mat')).detector;
outVidPath = fullfile(dstDir,'blob_tracking.mp4');
% Video frames and network input size
startFrame = 0; endFrame = 998; fps = 15; netInputSize = [256 256 3];  
% Plasma visualization 
intensityLim = [0 1]; nContours = 35; contourSigma = 1.0; cmap = viridis(256);
% Tracking parameters 
scoreThresh = 0.45; costOfNonAssignment = 70; invisibleForTooLong = 25; 
ageThreshold = 4; minVisibleCount = 2;    
% Video writer
vid = VideoWriter(outVidPath,'MPEG-4'); vid.FrameRate = fps; open(vid);
% multiObjectTracker setup
measNoise = 90*eye(2);
tracker = multiObjectTracker( ...
    'FilterInitializationFcn', @(detection) initcvkf(detection), ... 
    'AssignmentThreshold', [costOfNonAssignment Inf], ...
    'ConfirmationThreshold', [minVisibleCount ageThreshold], ...
    'DeletionThreshold', [invisibleForTooLong invisibleForTooLong], ...
    'MaxNumSensors', 1);
% Tracking loop
frameIdx = 0;
for k = startFrame:endFrame
    frameIdx = frameIdx + 1;
    framePath = fullfile(srcDir, sprintf('%05d_img1.png', k));
    if ~isfile(framePath), continue; end
    % Read grayscale and build a visualization frame (RGB) at net size
    imgGray = im2double(imread(framePath));
    bright  = min(max(1 - imgGray, intensityLim(1)), intensityLim(2));
    bright  = imresize(bright, netInputSize(1:2));
    visRGB  = plasmaVisRGB(bright, cmap);
    % For trained detector, input RGB image
    netImg = imread(framePath);
    if size(netImg,3)==1, netImg = repmat(netImg,1,1,3); end
    netImg = imresize(netImg, netInputSize(1:2));
    % Detect blobs 
    [bboxes, scores] = detect(detector, netImg); keep = scores >= scoreThresh;
    bboxes = double(bboxes(keep,:)); scores = double(scores(keep));
    % Build detections as objectDetection (centroids)
    c = [bboxes(:,1)+bboxes(:,3)/2, bboxes(:,2)+bboxes(:,4)/2];
    time = frameIdx;
    detections = cell(size(c,1),1);
    for di = 1:size(c,1)
        detections{di} = objectDetection(time, c(di,:).', ...
            'MeasurementNoise', measNoise, ...
            'SensorIndex', 1, ...
            'ObjectAttributes', struct( ...
                'BoundingBox', bboxes(di,:), ...
                'Score', scores(di)));
    end
    % Update tracker
    trks = tracker(detections, time);
    visRGB = drawPlasmaContours(visRGB, bright, nContours, contourSigma);
    % Draw tracks (center bbox at KF position)
    out = visRGB;
    for i = 1:numel(trks)
        bb = double(trks(i).ObjectAttributes.BoundingBox);
        % multiObjectTracker state for initcvkf: [x; vx; y; vy]
        ctr = [trks(i).State(1), trks(i).State(3)];
        bb(1:2) = ctr - bb(3:4)/2;
        out = insertShape(out,'Rectangle',bb,'Color','white','LineWidth',2);
        out = insertText(out, bb(1:2), sprintf('%d', trks(i).TrackID), ...
            'TextColor','yellow','BoxOpacity',0,'FontSize',16);
    end
    writeVideo(vid, out);
end
close(vid);
disp("Saved: " + string(outVidPath));

