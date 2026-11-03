function INFO = getPristineCondition(root,tests)
INFO = struct();
% Loop through each test
for i = 1:numel(tests)
    t = tests(i); S = load(fullfile(root,sprintf("Test_%d_run_1.mat",t)));
    % Extract steady-state and transient data
    ss = S.measurement.steadyState; tr = S.measurement.transient;
    N  = numel(ss);
    % Extract flange temperature and timestamps
    Tf = arrayfun(@(x)double(x.timeDomain.flangeTemperature),ss)';
    ts = arrayfun(@(x)double(x.timeEpoch),ss)';
    % Smooth flange temperature to reduce noise
    Tf = smoothdata(smoothdata(Tf,'movmedian',31),'movmean',51);
    % Compute slope magnitude
    g = smoothdata(abs([0;diff(Tf)]),'movmean',21);
    flat = g < 0.05;    % Detect near flat regions
    d = diff([0;flat;0]); a = find(d==1); b = find(d==-1)-1;
    % Find plateau after five-step establishment
    estEndSS = 1; L = .02*N; high = Tf > .8*max(Tf);
    for k = 1:numel(a)
        if (b(k)-a(k)+1) > L && mean(high(a(k):b(k))) > .8
            estEndSS = a(k);
            break
        end
    end
    % Extract transient timestamps and map the steady-state establishment time
    tt = arrayfun(@(x)double(x.timeEpoch),tr)';
    [~,estEndTR] = min(abs(tt-ts(estEndSS)));
    % Store results
    INFO(i).test = t; INFO(i).estEnd_ss = estEndSS; INFO(i).estEnd_tr = estEndTR;
end
end