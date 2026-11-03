%% Plot the HVAC fuzzy controller

h = waitbar(0,'HVAC Demo: plotting the rule base');

dFuzzy = HVACSimplestFuzzyController('initialize');
n = 30; % Number of samples

x = linspace(dFuzzy.input(1).range(1),dFuzzy.input(1).range(2),n);
y = linspace(dFuzzy.input(2).range(1),dFuzzy.input(2).range(2),n+2);

z = zeros(n,n+2);
for k = 1:n
  for j = 1:n+2  
    z(k,j) = FuzzyInference([x(k),y(j)], dFuzzy);
  end
  waitbar(k/n)
end
close(h);

NewFigure('State from Fuzzy Logic');
surf(x,y,z');
xlabel(dFuzzy.input(1).name)
ylabel(dFuzzy.input(2).name)
zlabel('State')
colorbar


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
