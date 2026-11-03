%% FUZZYRAND Compute random inputs within range of the fuzzy input sets
%% Inputs
% system (.) Fuzzy system from BuildFuzzySystem
%% Outputs
% y      (n) Random crisp values of the inputs

function y = FuzzyRand(system)

if nargin==0
  system = SmartWipersSystem;
  y = FuzzyRand(system)
  return;
end

nIn = length(system.input);
y   = ones(1,nIn);

for k = 1:nIn
  range = system.input(k).range;
  y(k)  = range(1) + (range(2)-range(1))*rand(1);
end

