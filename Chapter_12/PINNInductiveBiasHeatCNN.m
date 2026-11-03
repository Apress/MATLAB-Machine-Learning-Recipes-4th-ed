%% Heat diffusion data processed 
% Flatten for MLP:
Xtrain_flat = reshape(Xtrain, [], size(Xtrain,4)).';
Ytrain_flat = reshape(Ytrain, [], size(Ytrain,4)).';
Xtest_flat  = reshape(Xtest,  [], size(Xtest,4)).';
Ytest_flat  = reshape(Ytest,  [], size(Ytest,4)).';
%% CNN (local spatial bias that matches diffusion)
layersCNN = [
    imageInputLayer([nx ny 1],"Normalization","none")
    convolution2dLayer(5,32,"Padding","same"); reluLayer
    convolution2dLayer(5,16,"Padding","same"); reluLayer
    convolution2dLayer(3,8,"Padding","same");  reluLayer
    convolution2dLayer(3,1,"Padding","same")
    regressionLayer
];
%% MLP (unstructured mapping)
layersMLP = [
    featureInputLayer(nx*ny,"Normalization","none")
    fullyConnectedLayer(800); reluLayer
    fullyConnectedLayer(800); reluLayer
    fullyConnectedLayer(nx*ny)
    regressionLayer
];
% Training:
 netCNN = trainNetwork(Xtrain,      Ytrain,      layersCNN, opts);
 netMLP = trainNetwork(Xtrain_flat, Ytrain_flat, layersMLP, opts);
% Prediction:
 pCNN = predict(netCNN, Xtest);
 pMLP = predict(netMLP, Xtest_flat);