function mosfetEvaluateExp(results, modelInfo, evalIds, tag)
data = results(ismember([results.test], evalIds));
% Extract trained model parameters
threshold = modelInfo.threshold; step = modelInfo.step; 
onsetLevel = modelInfo.onsetLevel; m0 = modelInfo.model; 
allTrue = []; allPred = []; nData = numel(data); 
nCols = 2; nPairs = ceil(nData/nCols); 
for i = 1:nData
    yRaw = data(i).drds_on(:); yD = smoothdata(yRaw, 'movmedian', 101);
    % Shift signal to positive domain
    if min(yD) < 0, yD = yD - min(yD) + 1e-4; end
    n = numel(yD); % Signal length
    % Detect degradation onset index
    s = find(yD >= onsetLevel, 1, 'first'); 
    if isempty(s), s = n; end
    % Detect failure index using threshold
    f = find(yD >= threshold, 1, 'first'); 
    if isempty(f), f = n; end
    % Downsample degradation trajectory
    idxC = 1:step:n; yC = yD(idxC);  yC = smoothdata(yC,'movmean',3); 
    kOnset = find(idxC >= s, 1, 'first'); % Locate onset in downsampled signal
    % Initialize model using trained parameters
    mdl = exponentialDegradationModel( ... 
        'Theta', m0.Theta, 'ThetaVariance', m0.ThetaVariance, ...
        'Beta', m0.Beta, 'BetaVariance', m0.BetaVariance, ...
        'Phi', m0.Phi, 'NoiseVariance', m0.NoiseVariance, ...
        'SlopeDetectionLevel', m0.SlopeDetectionLevel);
    if isempty(kOnset), kOnset = numel(idxC); end
    predC = nan(numel(yC),1);
    for k = max(3, kOnset+1):numel(yC)
        tNow = k - kOnset; % Relative time since onset
        update(mdl, [tNow yC(k)]); % Update model 
        rulHat = predictRUL(mdl, threshold); % Predict remaining useful life
        predC(k) = rulHat / max(tNow + rulHat, eps); % Normalize predicted RUL
    end
    predFull = nan(n,1); good = isfinite(predC);
    % Interpolate predictions to full trajectory
    predFull = interp1(idxC(good), predC(good), 1:n, 'linear', 'extrap')'; 
    predFull = min(max(predFull, 0), 1); % Clamp predictions to valid range [0,1]
    trueRUL = nan(n,1);
    % Compute onset-relative normalized RUL
    if s < f
        trueRUL(s:f) = (f - (s:f)') / (f - s); 
    else
        trueRUL(s:end) = 0;
    end
    if f < n, trueRUL(f+1:end) = 0; end
    valid = isfinite(predFull) & isfinite(trueRUL); % Collect valid prediction samples
    allTrue = [allTrue; trueRUL(valid)]; allPred = [allPred; predFull(valid)];
end
mse = mean((allTrue - allPred).^2); mae = mean(abs(allTrue - allPred)); 
rmse = sqrt(mse); denom = sum((allTrue - mean(allTrue)).^2);
r2 = 1 - sum((allTrue - allPred).^2) / denom; 
fprintf('\n%s results\n', tag); % Print evaluation results
fprintf('Eval onset = fixed training level\n');
fprintf('Onset level = %.6f\n', onsetLevel);
fprintf('RUL metric = onset-relative normalized RUL\n');
fprintf('MSE = %.6f\n', mse); fprintf('MAE = %.6f\n', mae);
fprintf('RMSE = %.6f\n', rmse); fprintf('R^2 = %.6f\n', r2);
end