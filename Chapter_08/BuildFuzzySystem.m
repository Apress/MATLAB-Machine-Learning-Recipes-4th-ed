function d = BuildFuzzySystem(varargin)

%% BUILDFUZZYSYSTEM Builds a fuzzy logic system data structure. 
% As you build the system you must input id for inputs, outputs and rules. The
% default is 1.
%% Form
%  d = BuildFuzzySystem(varargin)
%
%% Inputs
%   varargin {:} Parameter pairs
%                 id              Index for the input, output or rule
%                 input comp      Cell array of label strings
%                 input type      'Trapezoid'  or 'Triangle'
%                 input name      Name of input
%                 input params    Parameters defining the input
%                 input range     Input range
%                 output comp     Cell array of label strings
%                 output type     'Trapezoid'  or 'Triangle'
%                 output name     Name of output
%                 output params   Parameters defining the output
%                 output range    Output range
%                 rule input      Input indices (match rule to input)
%                 rule output     Output indices (match rule to output)
%                 rule operator   Rule operator (fuzzy and or or)
%                 implicate       Implicate method
%                 aggregate       Aggregation method
%                 defuzzify       Type of defuzzifier
%                 data            Data for the fuzzy system
%
%% Outputs
%   d       (.)	Data structure
%                 .input     (n) Input struct array
%                                .name   ''   char name
%                                .comp  {''}  cell array of strings
%                                .type  {@}   cell array of function handles
%                                .range (1,2) data range
%                                .params {[]} cell array of params
%                 .output    (m) Output struct array
%                                .name   ''   char name
%                                .comp  {''}  cell array of strings
%                                .type  {@}   cell array of function handles
%                                .range (1,2) data range
%                                .params {[]} cell array of params
%                 .rules     (p) Rules struct array
%                                .input   (1,n) Input set indices
%                                .output  (1,m) Output set indices
%                                .operator @    Function handle
%                 .implicate  @  Function handle
%                 .aggregate  @  Function handle
%                 .defuzzify  @  Function handle
%

d = struct;
j = 1;

for k = 1:2:length(varargin)
  switch (lower(varargin{k}))
    case 'id'
      j = varargin{k+1};
    case 'input comp'
      d.input(j).comp = varargin{k+1};
    case 'input type'
      d.input(j).type = varargin{k+1};
    case 'input name'
       d.input(j).name = varargin{k+1};
    case 'input params'
      d.input(j).params = varargin{k+1};
    case 'input range'
      d.input(j).range = varargin{k+1};
    case 'output comp'
      d.output(j).comp = varargin{k+1};
    case 'output type'
      d.output(j).type = varargin{k+1};
    case 'output name'
      d.output(j).name = varargin{k+1};
    case 'output params'
      d.output(j).params = varargin{k+1};
    case 'output range'
      d.output(j).range = varargin{k+1};
    case 'rule input'
      d.rules(j).input = varargin{k+1};
    case 'rule output'
      d.rules(j).output = varargin{k+1};
    case 'rule operator'
       d.rules(j).operator = varargin{k+1};
    case 'implicate'
       d.implicate = varargin{k+1};
    case 'aggregate'
       d.aggregate = varargin{k+1};
    case 'defuzzify'
       d.defuzzify = varargin{k+1};
    case 'data'
       d.data = varargin{k+1};
    otherwise
      fprintf(1,'%s not available\n',varargin{k});
  end
end

if ~isfield(d,'rules')
  return;
end

% match rules to sets if cell array
for k = 1:length(d.rules)
  inputs = d.rules(k).input;
  if iscell(inputs)
    nIn = length(inputs);
    input = zeros(1,nIn);
    for j = 1:nIn
      comp = d.input(j).comp;
      val = find(contains(comp,inputs(j)));
      if ~isempty(val)
        input(j) = val;
      end
    end
    d.rules(k).input = input;
  end
  outputs = d.rules(k).output;
  if iscell(outputs)
    nOut = length(outputs);
    output = zeros(1,nOut);
    for j = 1:nOut
      comp = d.output(j).comp;
      val = find(contains(comp,outputs(j)));
      if ~isempty(val)
        output(j) = val;
      end
    end
    d.rules(k).output = output;
  end
end % array of rules
