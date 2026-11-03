clear;
% Input image
I = imread("people.JPG");
% Load pretrained model for human face detection
[faceBoxes, faceScores, keypoints] = mtcnn.detectFaces(I);
% Threshold
minScore = 0.90;
keep = faceScores >= minScore;
faceBoxes = faceBoxes(keep,:);
disp(size(keypoints));
% "keypoints" is n x 5 x 2, where n is number of detected faces, 
% The 5 keypoints are: right and left eye, nose, two mouth corners  
keypoints = keypoints(keep,:,:);

% Function to create rectangle coordinates out of a point
mk = @(p,w,h)[max(1,min(p(1)-w/2,size(I,2)-w)) max(1,min(p(2)-h/2,size(I,1)-h)) w h];

% Adding boxes around detected keypoints 
labels = ["face","left eye","right eye","nose","mouth"];
colors = uint8([0 255 0; 0 255 255; 0 255 255; 255 255 0; 255 0 255]);
allBoxes=[]; allColors=uint8(zeros(0,3));
for k = 1:size(faceBoxes,1)
    faceBox = faceBoxes(k,:);
    pts = squeeze(keypoints(k,:,:));              
    eyeW   = 0.25*faceBox(3);  eyeH   = 0.10*faceBox(4);
    noseW  = 0.26*faceBox(3);  noseH  = 0.09*faceBox(4);
    mouthW = 0.45*faceBox(3);  mouthH = 0.18*faceBox(4);
    mouthCenter = mean(pts(4:5,:),1) + [0 0.07*faceBox(4)];
    allBoxes  = [allBoxes; round([ ...
        faceBox; ...
        mk(pts(1,:), eyeW,  eyeH); ...        % left eye
        mk(pts(2,:), eyeW,  eyeH); ...        % right eye
        mk(pts(3,:), noseW, noseH); ...       % nose
        mk(mouthCenter, mouthW, mouthH)])];   % mouth
    allColors = [allColors; colors];
end

% Draw results and legend
box = insertShape(I,"rectangle",allBoxes,"Color",allColors,"LineWidth",4);
x = 15; y = 15; rowH = 54; sw = 34; pad = 16; fontSz = 38;   
legendW = 320; legendH = rowH*numel(labels) + 16;
box = insertShape(box,"filled-rectangle",[x-14 y-12 legendW legendH], ...
    "Color","black","Opacity",0.60);
for i=1:numel(labels)
    yy = y + (i-1)*rowH;
    box = insertShape(box,"filled-rectangle",[x yy sw sw],"Color", ...
        colors(i,:),"Opacity",0.95);
    box = insertText(box,[x+sw+pad yy-6],char(labels(i)), ...
        "FontSize",fontSz,"BoxOpacity",0,"TextColor","white");
end
imshow(box);
