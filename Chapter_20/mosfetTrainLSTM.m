
function lstmInfo = mosfetTrainLSTM(results, trainIds, win, ageScale)
XTrain = {}; YTrain = [];
for i = 1:numel(trainIds)
    id = trainIds(i);
    % Get delta Rds(on) degradation signal for current device
    s = results([results.test] == id).drds_on(:);
    N = numel(s); % Signal length
    age = (0:N-1)' / ageScale; % Age feature
    s = s - min(s); % Normalize degradation signal so it starts at zero
    s = s ./ (max(s) + eps); % Scale to [0,1]
    rul = (N-1:-1:0)' / max(N-1,1); % RUL 1 at start and 0 at failure
    % Sliding windows - degradation + age as input
    for t = win:N
        XTrain{end+1,1} = [s(t-win+1:t), age(t-win+1:t)]'; 
        YTrain(end+1,1) = rul(t); % Target output
    end
end
% Model architecture
layers = [
    sequenceInputLayer(2,"Name","seq_in")
    lstmLayer(15,"OutputMode","last","Name","lstm")
    reluLayer("Name","relu")
    fullyConnectedLayer(1,"Name","fc_out")
    regressionLayer("Name","reg")
];
opts = trainingOptions("adam", ...
    "MaxEpochs", 100, ...
    "MiniBatchSize", 64, ...
    "InitialLearnRate", 1e-3, ...
    "Shuffle", "every-epoch", ...
    "SequenceLength", "shortest", ...
    "Verbose", true, ...
    "Plots", "training-progress");
% Train model 
net = trainNetwork(XTrain, YTrain, layers, opts);
% Store
lstmInfo.net = net; lstmInfo.win = win;lstmInfo.ageScale = ageScale;
end