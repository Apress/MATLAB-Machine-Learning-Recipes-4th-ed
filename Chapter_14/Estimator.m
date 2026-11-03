%% Demonstrate roll/yaw control and disturbance estimation

% Constants
r2D   = 180/pi;
n2Nm  = 1e6;

% Number of time steps
n     = 10000;
nDays = 16;

%% Disturbances
p  = 86400; % One day is the period (s)
wO = 2*pi/p; % Orbit rate (rad/sec)
hW = 62.8; % Momentum bias (Nms)

t  = linspace(0,nDays*p,n);
dT = t(2);

% Disturbance model 
tD = [1e-6 + 2e-6*sin(wO*t) + 2e-7*sin(2*wO*t);...
      2e-6 + 1e-6*cos(wO*t) - 1e-7*cos(2*wO*t)]; % Disturbance (Nm)
yL = {'Roll (\muNm)' 'Yaw (\muNm)'};
TimeHistory(t,tD*n2Nm,yL,'Disturbances');

%% Roll/yaw control simulation
dist  = true;

% Control gain
sigma = 2*wO; % Undamped natural frequency
zeta  = 0.7071; % Damping ratio
b     = -2*zeta*sigma;
a     = (wO - sigma^2/wO);
gain  = hW*[-a;b];

% Simulate
x     = [0.1;0]/r2D; % Initial error in degrees
xP    = zeros(6,n);
d     = struct('wO',wO,'hW',hW,'tD',[0;0],'tC',[0;0]);
if( ~dist )
  tD = zeros(2,n); %#ok<UNRCH>
end
for k = 1:n
  d.tC    = gain*x(1);
  d.tD    = tD(:,k);
  xP(:,k) = [x*r2D;tD(:,k)*n2Nm;d.tC*n2Nm];
  x       = RK4(@RHSRY,x,dT,0,d);
end

yL = {'Roll (deg)' 'Yaw (deg)', 'T_{D_x} (\muNm)' 'T_{D_z} (\muNm)' ...
      'T_{C_x} (\muNm)' 'T_{C_z} (\muNm)'};
TimeHistory(t,xP,yL,'RY Control');

%% Roll/yaw estimator

% Simulate
x     = [0.1;0]/r2D; % Initial error in degrees
xP    = zeros(6,n);
dE    = DisturbanceEstimator('data structure');
dE.dT = t(2);
dE    = DisturbanceEstimator('initialize',dE);
for k = 1:n
  d.tC    = gain*x(1);  
  dE      = DisturbanceEstimator('update',dE,x,d.tC);

  d.tD    = tD(:,k);
  xP(:,k) = [x*r2D;dE.xE(1:2)*r2D;dE.tE*n2Nm];
  x       = RK4(@RHSRY,x,dT,0,d);
end

yL = {'Roll (deg)' 'Yaw (deg)',...
      'Roll_E (deg)' 'Yaw_E (deg)'...
      'T_{D_x} (\muNm)' 'T_{D_z} (\muNm)' };
TimeHistory(t,xP,yL,'RY Control with Estimator');
