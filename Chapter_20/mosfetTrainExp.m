function modelInfo = mosfetTrainExp(results, trainIds)
train = results(ismember([results.test], trainIds));
% Failure threshold, fit threshold and downsampling step
threshold = 0.055; fitThreshold = 0.1; step = 8; 
trainVectors = {}; onsetLevels = [];
for i = 1:numel(train)
    yD = smoothdata(train(i).drds_on(:), 'movmedian', 101);
    % Shift signal to be positive (to be compatible with exp. model)
    if min(yD) < 0, yD = yD - min(yD) + 1e-4; end 
    % We want the exp. model to fit up until this point 
    fFit = find(yD >= fitThreshold, 1, 'first'); 
    % Estimate degradation onset index
    s = detectOnsetByLogLinearity(yD, fFit, step); 
    onsetLevels(end+1,1) = yD(s); 
    % Downsampledonset-to-fit-threshold samples
    yC = yD(s:step:fFit); 
    trainVectors{end+1,1} = yC; 
end

% Initialize model
mdl = exponentialDegradationModel('SlopeDetectionLevel',0.05); 
fit(mdl,trainVectors); % estimate model parameters from training trajectories

% Save model info
modelInfo.model = mdl;
modelInfo.threshold = threshold; modelInfo.step = step; 
modelInfo.onsetLevels = onsetLevels; modelInfo.onsetLevel = median(onsetLevels);
end

% Selects degradation starting point of the most exponential-like segment
function sBest = detectOnsetByLogLinearity(yD, f, step)
n = numel(yD); % signal length
candEnd = min(f - 10, round(0.4 * n)); % latest candidate onset to test
bestCost = inf; sBest = 1;
for s = 1:candEnd
    yC = yD(s:step:f); 
    if numel(yC) < 5 || any(yC <= 0), continue; end 
    tC = (0:numel(yC)-1)'; % local time vector
    p = polyfit(tC, log(yC), 1); % fit exponential trend in log-domain
    cost = mean((log(yC) - polyval(p, tC)).^2); % mean squared log-fit error
    if cost < bestCost % keep the most exponential segment
        bestCost = cost; sBest = s;
    end
end
end