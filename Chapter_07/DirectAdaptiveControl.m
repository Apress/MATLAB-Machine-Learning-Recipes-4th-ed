%% Direct adaptive control demo
% Reference: ECE 517: Nonlinear and Adaptive Control Lecture Notes
% Daniel Liberzon November 3, 2021

n      = 1000;
dT     = 0.1;

% Plant
a      = 0.1;
b      = 1;
x      = 0.1;

% Initial gain
gain   = 0.1;

% Storage
xP     = zeros(3,n);
for k = 1:n
  gain       = gain + dT*x^2;
  u          = -gain*x;
  xP(:,k)    = [x;u;gain];
  x          = RungeKutta(@RHS,0,x,dT,a,b,u);
end

yL = {'x','u','K'};

t  = (0:n-1)*dT;

TimeHistory(t,xP,yL,'Direct Adaptive Control');

%% Right hand side
function xDot = RHS(~,x,a,b,u)

xDot = a*x + b*u;

end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
