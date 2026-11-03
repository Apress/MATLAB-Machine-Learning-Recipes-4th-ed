function mosfetEvaluateLSTM(results, lstmInfo, evalIds, tag)
data = results(ismember([results.test], evalIds));
% Extract trained model and parameters
net = lstmInfo.net; win = lstmInfo.win; ageScale = lstmInfo.ageScale;
allTrue = []; allPred = [];
for i = 1:numel(data)
    % Get degradation signal for current device
    yRaw = data(i).drds_on(:);  
    N = numel(yRaw);  
    % Compute normalized age feature
    age = (0:N-1)' / ageScale;
    % Normalize degradation signal to [0,1]
    yNorm = yRaw - min(yRaw); 
    yNorm = yNorm ./ (max(yNorm) + eps);
    % True normalized RUL trajectory
    trueRUL = (N-1:-1:0)' / max(N-1,1); 
    % Prepare sliding window sequences (degradation + age)
    XSeq = cell(max(N-win+1,0),1);
    for t = win:N
        XSeq{t-win+1,1} = [yNorm(t-win+1:t), age(t-win+1:t)]';
    end
    % Predict RUL using trained LSTM
    predRUL = nan(N,1);
    if ~isempty(XSeq)
        yPredLocal = predict(net, XSeq, "MiniBatchSize", 64);
        predRUL(win:end) = yPredLocal;
    end
    % Clamp predictions to valid range [0,1]
    predRUL = min(max(predRUL, 0), 1);
    % Collect valid predictions
    valid = isfinite(predRUL) & isfinite(trueRUL);
    allTrue = [allTrue; trueRUL(valid)]; 
    allPred = [allPred; predRUL(valid)];
end
% Compute evaluation metrics
mse = mean((allTrue - allPred).^2); mae = mean(abs(allTrue - allPred));
rmse = sqrt(mse); denom = sum((allTrue - mean(allTrue)).^2);
r2 = 1 - sum((allTrue - allPred).^2) / denom;
% Print results
fprintf('\n%s LSTM results\n', tag);
fprintf('RUL metric = full-trajectory normalized RUL\n');
fprintf('MSE = %.6f\n', mse);  fprintf('MAE = %.6f\n', mae);
fprintf('RMSE = %.6f\n', rmse); fprintf('R^2 = %.6f\n', r2);
end