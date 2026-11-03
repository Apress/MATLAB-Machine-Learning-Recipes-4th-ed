%% Test a recursive learning system

w   = rand(4,1); % Initial guess
Z   = randn(4,4); 
Y   = Z'*w;

wN  = w + 0.1*randn(4,1); % True weights are a little different
n   = 100;        % Number of measurements
zA  = randn(4,n); % Random inputs
y   = wN'*zA;     % New measurements

% Batch training
p   = inv(Z*Z'); % Initial value
w   = p*Z*Y; % Initial value

%% Recursive learning
dW = zeros(4,n);
for j = 1:n
  z       = zA(:,j);
  p       = p - p*(z*z')*p/(1+z'*p*z);
  w       = w + p*z*(y(j) - z'*w);
  dW(:,j) = w - wN; % Store for plotting
end

%% Plot the results
yL = cell(1,4);
for j = 1:4
  yL{j} = sprintf('\\Delta W_%d',j);
end

PlotSet(1:n,dW,'x label','Sample','y label',yL,...
        'plot title','Recursive Training',...
        'figure title','Recursive Training');


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
