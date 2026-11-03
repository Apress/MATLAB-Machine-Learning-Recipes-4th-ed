clear; clc; close all;
% Paths
dataFolder  = "/TurbofanEngines/CMAPSSData";
subDataset  = "FD001";     
trainFile = fullfile(dataFolder, "train_" + subDataset + ".txt");
testFile  = fullfile(dataFolder, "test_"  + subDataset + ".txt");
rulFile   = fullfile(dataFolder, "RUL_"   + subDataset + ".txt");

% Load ground truth 
yTrue = readmatrix(rulFile);

% Load train
M = readmatrix(trainFile);
M(:, all(isnan(M),1)) = [];
nCols = size(M,2);

% Exclude operational settings (cols 3:5) 
M = M(:, [1 2 6:nCols]);
nCols = size(M,2);
nSensors = nCols - 2;

varNames = ["id","time", ...
            "sensor_" + (1:nSensors)];
T = array2table(M,"VariableNames",cellstr(varNames));
ids = unique(T.id);
trainData = arrayfun(@(id) T(T.id==id,:), ids,"UniformOutput",false);

timeVar = "time";
sensorVars = varNames(3:end);

% Load test
M = readmatrix(testFile);
M(:, all(isnan(M),1)) = [];
nCols = size(M,2);

% Exclude operational settings (cols 3:5)
M = M(:, [1 2 6:nCols]);
T = array2table(M,"VariableNames",cellstr(varNames));
ids = unique(T.id);
testData = arrayfun(@(id) T(T.id==id,:), ids,"UniformOutput",false);

% Drop near-constant sensors
trainAll = vertcat(trainData{:});
keep = true(size(sensorVars));
for k = 1:numel(sensorVars)
    x = trainAll.(sensorVars(k));
    if (std(x) < 1e-12) || ((max(x) - min(x)) < 1e-2)
        keep(k) = false;
    end
end

droppedSensors = sensorVars(~keep);
sensorVars = sensorVars(keep);

fprintf("\nDropped constant/near-constant sensors (%d):\n", numel(droppedSensors));
disp(droppedSensors.');

% Data normalization (Z-score)
mu = varfun(@mean,trainAll,"InputVariables",cellstr(sensorVars));
sd = varfun(@std, trainAll,"InputVariables",cellstr(sensorVars));
mu = mu{1,:};
sd = sd{1,:};
sd(sd==0) = 1;

for i = 1:numel(trainData)
    Xn = trainData{i}{:,cellstr(sensorVars)};
    Xn = (Xn - mu) ./ sd;
    Xn(~isfinite(Xn)) = 0;
    trainData{i}{:,cellstr(sensorVars)} = Xn;
end

for i = 1:numel(testData)
    Xn = testData{i}{:,cellstr(sensorVars)};
    Xn = (Xn - mu) ./ sd;
    Xn(~isfinite(Xn)) = 0;
    testData{i}{:,cellstr(sensorVars)} = Xn;
end


% Build RUL indicator for training data
for n = 1:numel(trainData)
    tbl = trainData{n}; tfail = max(tbl.(timeVar));
    RUL = tfail - tbl.(timeVar); tbl.lifetime = RUL ./ max(RUL);   % 1 -> 0
    trainData{n} = tbl;
end
%Similarity model expects 1-D curves, so we give one weighted curve of sensors
stackTrain = vertcat(trainData{:}); 
Z = stackTrain{:, cellstr(sensorVars)};
h = stackTrain.lifetime;
nComp = 1;
[~,~,~,~,beta] = plsregress(Z, h, nComp);
trainHI = cell(size(trainData));
testHI  = cell(size(testData));
for n = 1:numel(trainData)
    Zi = trainData{n}{:, cellstr(sensorVars)};
    raw = [ones(size(Zi,1),1) Zi] * beta;   % predicted lifetime (1-D)
    hi  = movmean(raw,[10 10]);
    hi  = hi + 1 - hi(1);
    trainHI{n} = hi(:);
end
% Do the same for test
for n = 1:numel(testData)
    Zi = testData{n}{:, cellstr(sensorVars)};
    raw = [ones(size(Zi,1),1) Zi] * beta;   
    hi  = movmean(raw,[10 10]);
    hi  = hi + 1 - hi(1);
    testHI{n} = hi(:);
end
% Construct similarity model 
mdlSim = residualSimilarityModel( ...
    "Method","poly2", "Distance","absolute", ...
    "NumNearestNeighbors",60, "Standardize",1);
fit(mdlSim,trainHI);
yPred = zeros(numel(testHI),1);
for i = 1:numel(testHI)
    yPred(i) = predictRUL(mdlSim,testHI{i});
end

% Performance metrics
err = yPred - yTrue(:);
score = 0;
rmse = sqrt(mean(err.^2));
mae  = mean(abs(err));
for i = 1:numel(err)
    d = err(i);
    if d < 0
        score = score + (exp(d/13)-1);
    else
        score = score + (exp(d/10)-1);
    end
end

%____________________________________
fprintf("\n %s \n",subDataset);
fprintf("RMSE  = %.4f\n",rmse);
fprintf("MAE   = %.4f\n",mae);
fprintf("Score = %.4f\n",score);

%% ---------------- PLOT ----------------
figure;
plot(yTrue,"LineWidth",1.5); hold on;
plot(yPred,"--","LineWidth",1.5);
grid on; legend("Actual","Predicted");
title("RUL (" + subDataset + ")");

