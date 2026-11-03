%% Low frequency roll/yaw dynamics

%% Inputs
% x     (2,1) [roll;yaw] (rad)
% t     (1,1) Time (s) (Unused)
% d     (.)   Data structure
%             .tD (2,1) Disturbance torque (Nm)
%             .tC (2,1) Control torque (Nm)
%             .wO (1,1) Orbit rate (rad/s)
%             .hW (1,1) Momentum bias (Nms)
%% Outputs
% xDot  (2,1) d[roll;yaw]/dt (rad/s)

function xDot = RHSRY(x,~,d)

% Total torque
tX  = d.tC(1) + d.tD(1);
tZ  = d.tC(2) + d.tD(2);

% Angular rate
wX  =   tZ/d.hW;
wZ  =  -tX/d.hW;

% State derivative
xDot = [ d.wO*x(2) + wX;...
        -d.wO*x(1) + wZ];
