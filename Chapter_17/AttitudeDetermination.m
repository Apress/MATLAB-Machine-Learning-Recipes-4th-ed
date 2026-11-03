%% Attitude determination using machine learning
% This is a regression problem. Single-axis rotation.

%% Get the images
cd YawImages
label = load('Label');
cd ..

n          = length(label.yaw);
s          = [64 64 1];
nTrain     = 800; % this must be less than the number of images available

% All the data
x          = zeros(s(1),s(2),s(3),n);
y          = label.yaw';

%% Put the images in x
cd YawImages

for k = 1:n
  i = imread(sprintf('YawImage%d.jpg',k));
  x(:,:,1,k) = i;
end

%% Separate into training and validation sets
i          = randperm(n,nTrain);

xTrain     = x(:,:,:,i);
yTrain     = y(i);
i          = setxor(1:n,i);
xVal       = x(:,:,:,i);
yVal       = y(i);

%% Display a few snapshots
NewFigure('Yaw Snapshots');
nI = 20;
idx = randperm(n/2,nI);
kS = sort(randi(n,1,nI)); % random selection
for i = 1:nI
	subplot(5,4,i);
	imshow(x(:,:,1,kS(i)));
  title(sprintf('%d: %3.1f deg',kS(i),y(kS(i))));
end

NewFigure('Yaw Training Histogram');
histogram(yTrain)
axis tight
ylabel('Counts')
xlabel('Rotation Angle')


%% Training setup
% This gives the structure of the convolutional neural net
layers = [
    imageInputLayer(s)
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    averagePooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer];
     
miniBatchSize  = 128;
validationFrequency = floor(numel(yTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',30, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{xVal,yVal}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',false);


%% Train
yawAttitudeNet = trainNetwork(xTrain,yTrain,layers,options);

%% Display
disp(layers)
disp(options)

%% Test
yPred = predict(yawAttitudeNet,xVal);
 
predError = yVal - yPred;

thr = 10;
numCorrect = sum(abs(predError) < thr);
numValImages = numel(yVal);

accuracy = numCorrect/numValImages;

squares = predError.^2;
rmse = sqrt(mean(squares));

fprintf('Root mean squared error %8.4f\n',rmse);
fprintf('Accuracy                %8.4f\n',accuracy);

NewFigure('Scatter Plot')
scatter(yPred,yVal,'+')
xlabel("Predicted Value")
ylabel("True Value")

hold on
plot([-60 60], [-60 60],'r--')


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
