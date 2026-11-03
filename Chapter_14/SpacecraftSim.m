%% Inertia estimation demo
% Demonstrate inertia estimation
%
%% See also
% RungeKutta, RHSSpacecraft

%% Initialize
nSim      = 100;            % Number of time steps
dT        = 1;            	% Time step (sec)
x         = [2.4;0.1;3];    % [angle;rate;mass fuel]
dRHS      = RHSSpacecraft; 	% Get the default data structure
dRHS.uE   = 300;
disp(dRHS)

%% Controller
kForward  = 0.05;
tau       = 10;
tCThresh  = 0.00;
kI        = 0.9; % Inertia filter gain

%% Simulation
xPlot     = zeros(7,nSim);
inrEst    = 1.01*(dRHS.i0 + dRHS.rF^2*x(3)) + 0.05*randn(1)*dRHS.i0;
dRHS.tC   = 0;

for k = 1:nSim
  % Control
  dRHS.tC = -inrEst*kForward*(x(1) + tau*x(2));
  % Collect plotting information
  [xDot,inrTrue] = RHSSpacecraft(0,x,dRHS);
  omegaDot = xDot(2); % from gyro
  if( abs(dRHS.tC) > tCThresh  )
    inrEst = kI*inrEst + (1-kI)*dRHS.tC/omegaDot;
  end
  xPlot(:,k) = [x;inrEst;dRHS.tD;dRHS.tC;inrTrue];
	% Propagate (numerically integrate) the state equations
	x = RungeKutta( @RHSSpacecraft, 0, x, dT, dRHS );
end

%% Plot the results
yL      = {'\theta (rad)' '\omega (rad/s)' 'm_f (kg)', ...
           'I (kg-m^2)' 't_d (Nm)' 't_c (Nm)' 'I (kg-m^2)' };
pL      = {'Angle', 'Rate', 'Fuel', 'Estimated Inertia',...
  'Disturbance Torque', 'Control Torque' 'True Inertia'};
[t,tL]  = TimeLabel(dT*(0:(nSim-1)));

PlotSet( t, xPlot(1:3,:), 'x label', tL, 'y label', yL(1:3),...
  'plot title', pL(1:3), 'figure title', 'States' );

PlotSet( t, xPlot(4:7,:), 'x label', tL, 'y label', yL(4:7),...
  'plot title', pL(4:7), 'figure title', 'Control' );

PlotSet(t,xPlot([4 7],:),'x label',tL,'y label',yL(7),...
  'legend',{{'Estimate','True'}},'plot set',{[1 2]});


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
