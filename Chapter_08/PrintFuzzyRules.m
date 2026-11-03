%% PRINTFUZZYRULES Print fuzzy rules to command line.
% Create a text printout of the fuzzy rules in the system.
%% Form
%  PrintFuzzyRules( sys )
%% Inputs
%  sys    (.)   Fuzzy system
%
%% Outputs
%  None.

function PrintFuzzyRules( sys )

if nargin==0
  % Built-in demo
  d = SmartWipersSystem;
  PrintFuzzyRules( d );
  return;
end

for k = 1:length(sys.rules)
  fprintf('\n%d. if ',k)
  for j = 1:length(sys.rules(k).input)
    kIn = sys.rules(k).input(j);
    fprintf('%s',sys.input(j).name)
    fprintf(' is ')
    fprintf('%s',sys.input(j).comp{kIn})
    fprintf(' ')
    if j<length(sys.rules(k).input)
      fprintf('%s ',func2str((sys.rules(k).operator)))
    end 
  end
  fprintf('then ')
  for j = 1:length(sys.rules(k).output)
    kOut = sys.rules(k).output(j);
    fprintf('\t%s',sys.output(j).name)
    fprintf(' is ')
    fprintf('%s',sys.output(j).comp{kOut})
    if j<length(sys.rules(k).input)
      fprintf('\t')
    end
  end
end
fprintf('\n')


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
