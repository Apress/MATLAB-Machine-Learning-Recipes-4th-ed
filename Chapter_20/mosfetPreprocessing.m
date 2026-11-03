function results = mosfetPreprocessing(dataFolder, runIds)
results = struct('test',{},'estEnd',{},'baseline',{},'index0',{},'rds_on',{},'drds_on',{});
% Get indices of 5 establishment stage from Flange temperature
tempInfo = getPristineCondition(dataFolder, runIds);
for k = 1:numel(runIds)
    data = load(fullfile(dataFolder, sprintf("Test_%d_run_1.mat", runIds(k))));
    transients = data.measurement.transient;
    % RDS(on) = VDS/ID with light Gaussian smoothing
    Vds = arrayfun(@(t) mean(t.timeDomain.drainSourceVoltage), transients)';
    Ids = arrayfun(@(t) mean(t.timeDomain.drainCurrent), transients)';
    rdsOn = smoothdata(Vds ./ Ids, 'gaussian', 5);
    n = numel(rdsOn);
    % Delta RDS(on) = RDS(on) - Pristine condition
    startIdx = min(n, tempInfo(k).estEnd_tr + 10);
    baseline = mean(rdsOn(startIdx:min(n, startIdx + 20)), 'omitnan');
    % Curve smoothing
    deltaRds = smoothdata(hampel(rdsOn - baseline, 21, 65), 'gaussian', 65);
    % Detect first abnormal jump (failure state) and keep only healthy state
    thr = 0.005;
    d = abs(diff(deltaRds));
    j = find(d(startIdx:end) > thr, 1, 'first');
    failIdx = numel(deltaRds) + 1;
    if ~isempty(j), failIdx = startIdx + j; end
    validIdx = startIdx:failIdx-1;
    transientIdx = (0:numel(validIdx)-1)';
    % Store processed data
    results(k) = struct('test', runIds(k), 'estEnd', tempInfo(k).estEnd_tr, ...
        'baseline', baseline, 'index0', transientIdx, ...
        'rds_on', rdsOn(validIdx), 'drds_on', deltaRds(validIdx));
end
end