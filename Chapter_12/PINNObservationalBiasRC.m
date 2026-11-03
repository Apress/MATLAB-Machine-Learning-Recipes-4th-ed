% Capacitor discharge equation
tau = 0.5; V0  = 1.0; T = linspace(0,2,300)';
Vtrue = V0 * exp(-T/tau);
% Noisy measurements
Vgood = max(Vtrue + 0.03*randn(size(Vtrue)), 0); % Good data
Vbad = Vtrue + 0.03*randn(size(Vtrue)); % Biased data
tailIdx = find(T > 1.2);
Vbad(tailIdx) = Vbad(tailIdx) - 0.05;
% Train / test split
rng(0)
idx = randperm(numel(T));
trainIdx = idx(1:210);      
testIdx  = idx(211:end);    
tTrain = T(trainIdx);
tTest  = T(testIdx);
Vgood_train = Vgood(trainIdx);
Vbad_train  = Vbad(trainIdx);
Vtrue_test = Vtrue(testIdx);
% Model architecture (same for both datasets)
layersMLP = [
    featureInputLayer(1,"Normalization","none")
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(1)
    regressionLayer
];
opts = trainingOptions("adam", "MaxEpochs",500, "MiniBatchSize",64, ...
    "Shuffle","every-epoch", "Verbose",false);
% Train
net_good = trainNetwork(tTrain, Vgood_train, layersMLP, opts);
net_bad  = trainNetwork(tTrain, Vbad_train , layersMLP, opts);
% Predict
Vpred_good = predict(net_good, tTest);
Vpred_bad  = predict(net_bad , tTest);
% Performance Metrics
mse_good = mean((Vpred_good - Vtrue_test).^2);
mse_bad  = mean((Vpred_bad  - Vtrue_test).^2);
fprintf('TEST MSE (MLP trained on viable data) vs truth: %.6g\n', mse_good);
fprintf('TEST MSE (MLP trained on erroneous data) vs truth: %.6g\n', mse_bad);