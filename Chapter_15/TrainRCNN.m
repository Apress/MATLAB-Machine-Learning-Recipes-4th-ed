% Convert groundTruth objects to tables that Faster R-CNN training expects
trainTbl = objectDetectorTrainingData(gTruth);
valTbl   = objectDetectorTrainingData(gTruth2);
% Name of the ROI label you wrote in the Image Labeler App
labelName = "deer";
% Create training & validation data
trainingData = combine(imageDatastore(trainTbl.imageFilename), boxLabelDatastore(trainTbl(:,labelName)));
validationData = combine(imageDatastore(valTbl.imageFilename), boxLabelDatastore(valTbl(:,labelName)));
inputSize = [512 512 3]; numClasses = 1;
% Estimate anchor boxes for better accuracy
trainingDataForAnchors = transform(trainingData,@(d)preprocess(d,inputSize));
anchorBoxes = estimateAnchorBoxes(trainingDataForAnchors,6);
% Build a Faster R-CNN layer graph using ResNet-50 as the backbone feature extractor
lgraph = fasterRCNNLayers(inputSize,numClasses,anchorBoxes, resnet50,"activation_40_relu");
% Ensure every training/validation sample is resized to inputSize and its bounding boxes are scaled accordingly
trainingData = transform(trainingData,@(d)preprocess(d,inputSize));
validationData = transform(validationData,@(d)preprocess(d,inputSize));
% Train detector
options = trainingOptions("sgdm", ...
    MaxEpochs=15, ...
    MiniBatchSize=2, ...
    InitialLearnRate=1e-3, ...
    ValidationData=validationData, ...
    Plots="training-progress");
detector = trainFasterRCNNObjectDetector(trainingData,lgraph,options);
% Test on one validation image
I = imread(valTbl.imageFilename{1}); I = imresize(I,inputSize(1:2));
[bboxes,scores] = detect(detector,I);
figure
imshow(insertObjectAnnotation(I,"rectangle",bboxes,scores))
title("Deer Detection Result")
% Helper function for resizing
function data = preprocess(data,targetSize)
scale = targetSize(1:2)./size(data{1},[1 2]);
data{1} = imresize(data{1},targetSize(1:2));
data{2} = bboxresize(data{2},scale);
end
