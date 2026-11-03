%% Script implementing the lander neural net
% You must create the data using GenerateLadarMeas. It creates
% the scans and the labels for each scan.

%% Load the data
d            = load('LadarMeasurements');

%% Create the sequences for training, testing and validation
nSets        = size(d.r,2);
fracTrain    = 0.6;
fracVal      = 0.2;
kTrain       = 1:floor(fracTrain*nSets);
kVal         = kTrain(end)+1:floor(fracVal*nSets)+kTrain(end);
kTest        = kVal(end)+1:nSets;

%% Randomize the data
k            = randperm(nSets);
rho          = d.rho(:,k);
r            = d.r(:,k);

for i = 1:nSets
  XData(:,:,1,i) = d.rho{i};
end

YTrain = reshape(d.r(:,kTrain),1,1,3,size(kTrain,2));
YTest  = reshape(d.r(:,kTest), 1,1,3,size(kTest,2));
YVal   = reshape(d.r(:,kVal), 1,1,3,size(kVal,2));

%% Training
% This gives the structure of the convolutional neural net
layers = [
    imageInputLayer([d.s 1])  
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)   
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)   
    
    fullyConnectedLayer(3)
    regressionLayer];
   
disp(layers)
     
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',6, ...
    'MiniBatchSize',100,...
    'ValidationData',{XData(:,:,1,kVal),YVal}, ...
    'ValidationFrequency',10, ...
    'ValidationPatience',inf,...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');
disp(options)
fprintf('Fraction for training %8.2f%%\n',fracTraining*100);

  
landerNet = trainNetwork(XData(:,:,1,kTrain),YTrain,layers,options);
 
 %% Test the neural net
YPred = predict(landerNet,XData(:,:,1,kTest));

save('LunarNet','landerNet')

