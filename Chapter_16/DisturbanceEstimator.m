%% Disturbance Estimator for roll and yaw
% This is a continuous time estimator.
% The roll disturbance includes a bias, orbit rate and twice orbit rate
% Yaw is the orbit rate and twice orbit rate disturbances 90 degrees out
% of phase from roll.
%
% You first do d = DisturbanceEstimator('initialize',d);
% Then d = DisturbanceEstimator('update,d,x);
% d = DisturbanceEstimator will give you d based on default q, w0, hW and
% r.
%
%% Inputs
% mode (1,:) 'initialize' or 'update'
% d     (.)   Data structure
%             q   (7,7) Plant noise matrix
%             r   (1,1) Roll noise covariance (rad^2)
%             wO  (1,1) Orbit rate (rad/s)
%             hW: (1,1) Bias momentum (Nms)
%             a:  (7,7) State matrix
%             b   (7,2) Disturbance matrix
%             c   (1,7) Measurement matrix
%             k   (7,1) Gain matrix
%
%% Outputs
% d     (.)   Data structure
%            .xE (7,1) States [roll;yaw;roll bias; harmonics]
%            .tE (2,1) Disturbance [roll;yaw]

function d = DisturbanceEstimator(mode,d,x,tC)

if( nargin < 1 )
  d = DisturbanceEstimator('initialize');
  disp('Data Structure')
  disp(d)
  disp('Estimator Gain')
  disp(d.k)
  clear d
  return
end

switch mode
  case 'data structure'
    d.q   = diag([1e-4 1e-3 1e-6 1e-6 1e-6 1e-6 1e-6].^2);
    d.r   = 1e-6;
    d.wO  = 2*pi/86400;
    d.hW  = 62.8;
    d.dT  = 1;

  case 'initialize'

    if( nargin < 2 )
      d.q   = diag([1e-4 1e-3 1e-6 1e-6 1e-6 1e-6 1e-6].^2);
      d.r   = 1e-6;
      d.wO  = 2*pi/86400;
      d.hW  = 62.8;
      d.dT  = 1;
    end

    n = d.wO;
    c = 1/d.hW;

    d.a = [0  n  -c -c  -c   0    0;...
          -n  0   0  0   0   c    c;...
           0  0   0  0   0   0    0;...
           0  0   0  0   0  -n    0;...
           0  0   0  0   0   0 -2*n;...
           0  0   0  n   0   0    0;...
           0  0   0  0 2*n   0    0];

    eig(d.a)

    d.b = [0 c;c 0;0 0;0 0;0 0;0 0;0 0];
    d.c = [1 0 0 0 0 0 0];

     % d.a = d.a([1 2 4 5 6 7],[1 2 4 5 6 7]);
     % d.c = [1 0 0 0 0 0];
     % d.b = [0 c;c 0;0 0;0 0;0 0;0 0];
     % d.q = d.q(1:6,1:6);
     % 
    d.k = QCE( d.a, d.c, d.q, d.r);
    d.xE = zeros(7,1);
    disp('Estimator eigenvalues')
    disp(eig(d.a-d.k*d.c))

     [d.a,d.b] = C2DZOH(d.a,d.b,d.dT);

  case 'update'
    d.xE = d.a*d.xE + d.k*(x(1) - d.c*d.xE) + d.b*tC;
    d.tE = [sum(d.xE(2:4));sum(d.xE(5:6))];
end
