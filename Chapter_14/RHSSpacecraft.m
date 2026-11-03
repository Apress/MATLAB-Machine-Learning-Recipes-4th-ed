%% RHSSPACECRAFT Right hand side of spacecraft dynamics
%% Form
%  [xDot,inr] = RHSSpacecraft( ~, x, a )
%
%% Description
% A single-axis spacecraft dynamics model with a thruster.
% This can be called by the MATLAB Recipes RungeKutta function or any MATLAB
% integrator. Time is not used.
%
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (3,1) State vector [theta;omega;mFuel]
%  d       (.)   Data structure
%                .i0	(1,1) Inertia (kg-m^2)
%                .r   (1,1) Thruster moment arm (m)
%                .rF  (1,1) Fuel moment arm (m)
%                .tD  (1,1) Disturbance torque (Nm)
%                .tC  (1,1) Control torque (Nm)
%                .uE  (1,1) Thruster exhaust velocity (m/s)
%
%% Outputs
%  x       (3,1) State vector derivative dx/dt
%  inr     (1,1) Inertia (kg-m^2)
%

function [xDot, inr] = RHSSpacecraft( ~, x, d )

if( nargin < 1 )
  xDot = struct('i0',1,'r',0.1,'rF',0.1,'tD',0.00,'tC',0,'uE',700);
  return
end

inr       = d.i0 + d.rF^2*x(3);
mDot      = -abs(d.tC)/(d.r*d.uE);
tTotal    = d.tC + d.tD;
omegaDot  = tTotal/inr;
xDot      = [x(2);omegaDot;mDot];

