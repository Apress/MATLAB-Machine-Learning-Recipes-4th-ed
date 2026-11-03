%% Explore the fuzzy process in detail
% Load the Smart Wipers system and test it with a random input. Display the
% results in a table: the crisp input and resulting fuzzy membership, the
% crips output and fuzzy membership, and the strength of firing of each rule.

% Create the system
sys = SmartWipersSystem;

% Create a random fuzzy input
x = FuzzyRand(sys);

% Using verbose==true will create plots of the output aggregation
verbosity = true;
% Compute the crisp output
[y,data] = FuzzyInference( x, sys, verbosity );

%% Plot the input fuzzification
disp('------')
disp('Inputs')
disp('------')

nIn = length(sys.input);
for k = 1:nIn
  disp(sys.input(k).name)
  disp('----')
  fprintf('Crisp: %g\n',x(k))
  fprintf('Range: %g to %g\n',sys.input(k).range(:))
  tb = table(sys.input(k).comp',data.fuzzyX{k}','VariableNames',{'Set','Value'});
  disp(tb)
end

disp('Strength of rule firings:')
disp('----')
rules = table({sys.rules.input}',{sys.rules.output}',data.strength',...
  'VariableNames',{'Input','Output','Fire Strength'});
disp(rules)

%% Plot the fuzzy output results

disp('-------')
disp('Outputs')
disp('-------')

nOut = length(sys.output);
for k = 1:nOut
  disp(sys.output(k).name)
  disp('----')
  fprintf('Crisp: %g\n',y(k))
  fprintf('Range: %g to %g\n',sys.output(k).range(:))
  tb = table(sys.output(k).comp',data.fuzzyY{k}','VariableNames',{'Set','Value'});
  disp(tb)
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
