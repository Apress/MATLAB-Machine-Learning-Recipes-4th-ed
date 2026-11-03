% Vertical projectile motion
g  = 9.81;      % m/s^2 
v0 = 50;        % initial velocity
t = linspace(0,10,120)';          % time vector
y_true = v0.*t - 0.5*g.*t.^2;     % true trajectory
% Noisy measurements
rng(42);                           
noise = 3*randn(size(t));
y_measured = y_true + noise;
% Train / test split
idx = randperm(numel(t));
trainIdx = idx(1:25);
testIdx  = idx(26:end);
tTrain = t(trainIdx);
yTrain = y_measured(trainIdx);
tTest = t(testIdx);
yTest = y_true(testIdx);           
% Purely data-driven model (time only)
rawMdl = fitlm(tTrain, yTrain);         % linear regression in t
yRawHat = predict(rawMdl, tTest);
% Physics-informed model (t plus t^2)
XTrain = [tTrain tTrain.^2];            % physics-informed feature
XTest  = [tTest  tTest.^2];
physMdl = fitlm(XTrain, yTrain);
yPhysHat = predict(physMdl, XTest);
% Performance metrics
rmseRaw  = rms(yRawHat  - yTest);
rmsePhys = rms(yPhysHat - yTest);
fprintf('RMSE (raw)  = %.2f m\n', rmseRaw);
fprintf('RMSE (phys.) = %.2f m\n', rmsePhys);