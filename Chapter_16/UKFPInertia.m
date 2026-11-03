%% Demonstrate UKF parameter estimation with a rigid body.
% This estimates only inertia. The parameter estimator does not
% estimate the body state.
% -------------------------------------------------------------------------

%% Simulation setup
nSim          = 6600;
sigY          = 0.0001;
xP            = zeros(18,nSim);
x             = [0;0;0];
dT            = 0.1;

%% Estimation parameters
t   = 0;
y   = 0;
q   = 0.0001*eye(6);
r   = 0.00001*eye(3);
p   = 4*q;
d   = struct('u',[0;0;0],'w',[10 12 5 0.1 1 1]);


% The 'w' is the initial inertia estimate
dRHSUKF       	= struct('u',[0;0;0],'w',[12 11 7 0 0 0]);

dKF = KFInitialize( 'ukfp','x',x,'f',@RHSInrUKF,...
                    'fData',dRHSUKF,'r',r,'q',q,...
                    'p',p,'hFun','GXUKF',...
                    'dT',dT,'eta',[12 11 7 0 0 0]',...
                    'alpha',1e-3,'kappa',0,'beta',2);

dKF   = UKFPWeight( dKF );

%% Simulation
tPulseStop    = 5;
d.u           = [0;0;0];
uNext         = 10*(0.5*rand(3,1) - 0.5);
uNext         = [10;10;10];
tNext         = 20*rand;
tNext         = 0;


for k = 1:nSim

  % Plotting
  dKF.x            = x; % This must be before the propagation

  if( t >= tPulseStop )
    d.u     = [0;0;0];
    uNext      = 10*(0.5*rand(3,1) - 0.5);
    tNext      = t + 50*rand;
    tPulseStop = 5*rand + tNext;
  elseif( t >= tNext )
    d.u     = uNext;
  end
  xP(:,k) = [x; dKF.eta; diag(dKF.p);d.u];

  % Tell the filter about the inputs
  dKF.fData.u = d.u;

  % Update the RHS
  x       = RungeKutta( @RHSInrUKF, 0, x, dT, d );

  % Measurement
  y       = x + sigY*randn(3,1);
  t       = t + dT;

  % The Kalman Filter. This must be after the propagation
  dKF.t     = t;
  dKF.y     = y;
  dKF       = UKFPUpdate( dKF );

end

%% Plotting
t   = (0:(nSim-1))*dT;
yL  = {'\omega_x' '\omega_y' '\omega_z' 'u_x' 'u_y' 'u_z'};
leg = {'Ixx' 'Iyy' 'Izz' 'Ixy' 'Ixz' 'Iyz'};
Plot2D( t, xP( [1:3 16:18],:), 'Time (sec)', yL,      'Inertia Estimator: True States'     );
Plot2D( t, xP( 4: 9,:), 'Time (sec)', 'Inertia',    'Inertia Estimator: Inertia'    );
legend(leg{:})
Plot2D( t, xP(10:15,:), 'Time (sec)', 'Covariance', 'Inertia Estimator: Covariance' );
legend(leg{:})


%--------------------------------------
% $Date$
% $Id: b1f694c985bcd005f46ca3f1587307098b2fb32c $
