%% KFAuto  Demonstrate a Kalman Filter for relative motion of an automobile.
% The relative motion a single degree of freedom (2 state) system and
% additional random walk acceleration component. 
% The measurement is relative position
%
%% See also
% CToDZOH, KFInitialize, KFUpdate, KFPredict,
% TimeLabel, TimeHistory

rng('default');

%% Initialize
tEnd          = 100.0;            % Simulation end time (sec)
dT            = 0.1;              % Time step (sec)
mSigma        = 0.01;             % 1 sigma position measurement noise
ignoreRW      = true;

% xdot = a*x + b*u
a = [0 1 0 ;0 0 1 ;0 0 0 ]; % Continuous time model
b = [0 0;1 0;0 1]; % Continuous time input matrix

% x[k+1] = f*x[k] + g*u[k]
[f,g] = CToDZOH(a,b,dT);  % Discrete time model
x     = [10;0;0];       % Initial state
sig   = [1e-2; 1e-3]; % Model noise
if( ignoreRW )
  q     = [0; sig(1); 0].^2;      % Model noise covariance ;
else
  q     = [0; sig].^2;      % Model noise covariance ;
end
dKF   = KFInitialize('kf','m',x,'a',f,'b',g,'h',[1 0 0],...
                     'r',mSigma^2,'q',diag(q),'p',diag((0.01*x).^2),...
                     'u',[0;0]);

%% Simulation
nSim  = floor(tEnd/dT) + 1;
xPlot = zeros(7,nSim);

for k = 1:nSim
  % Position measurement with random noise
  y = x(1) + mSigma*randn(1,1);
  
  % Update the Kalman Filter
  dKF.y = y;
  dKF   = KFUpdate(dKF);
  
  % Plot storage
  xPlot(:,k) = [x;y;dKF.m-x];
  
  % Propagate the state equations
  x = f*x + g*(sig.*randn(2,1));
  
  % Propagate the Kalman Filter
  dKF   = KFPredict(dKF);
end

%% Plot the results
yL     = {'x_2' 'v_2' 'a_w' 'y' 'e_1' 'e_2' 'e_3' };
t      = dT*(0:(nSim-1));

if( ignoreRW)
  s = sprintf('Errors ignoring random walk');
else
  s = sprintf('Errors accounting for random walk');
end
j = 1:4;
TimeHistory( t, xPlot(j,:), yL(j), 'States' );
j = 5:7;
TimeHistory( t, xPlot(j,:), yL(j), s );

