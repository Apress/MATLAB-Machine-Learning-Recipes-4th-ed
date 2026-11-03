imdsTrain = imageDatastore(gTruth .DataSource.Source);
imdsVal   = imageDatastore(gTruth2.DataSource.Source);
% Masks and classes (add background)
pxTrain = string(gTruth .LabelData{:,1}); pxTrain = pxTrain(:)';
pxVal   = string(gTruth2.LabelData{:,1}); pxVal   = pxVal(:)';
fgNames = string(gTruth.LabelDefinitions.Name);
fgIDs = gTruth.LabelDefinitions.PixelLabelID;
if iscell(fgIDs), fgIDs = cell2mat(fgIDs); end
classes  = ["background"; fgNames(:)]; labelIDs = [0; double(fgIDs(:))];
% Pair image+label, resize to input
inputSize = [512 512 3];
dsTrain = combine(imdsTrain, pixelLabelDatastore(pxTrain,classes,labelIDs));
dsVal   = combine(imdsVal,   pixelLabelDatastore(pxVal,  classes,labelIDs));
rz = @(d){imresize(d{1},inputSize(1:2)), imresize(d{2},inputSize(1:2),"nearest")};
dsTrain = transform(dsTrain, rz); dsVal = transform(dsVal, rz);
% Train DeepLabv3+ with Resnet-18 backbone
lgraph = deeplabv3plusLayers(inputSize, numel(classes), "resnet18");
opts = trainingOptions("adam", InitialLearnRate=1e-4, MaxEpochs=15, ...
    MiniBatchSize=4, Shuffle="every-epoch", ValidationData=dsVal, ...
    ValidationFrequency=50, Verbose=true, Plots="training-progress");
net = trainNetwork(dsTrain, lgraph, opts);
% Test
I = imread("deerpic.jpg");
C = semanticseg(imresize(I,inputSize(1:2)), net);
C = imresize(C, size(I,[1 2]), "nearest");
figure("Color","w"); imshow(labeloverlay(I,C)); title("Deer Segmentation");
