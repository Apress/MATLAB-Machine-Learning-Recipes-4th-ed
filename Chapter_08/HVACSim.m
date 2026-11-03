%% Demonstrates a Fuzzy Logic Control System for HVAC
% It also includes a standard bang-bang with hysteresis controller for
% comparison. The external temperature stars out higher than the setpoint
% for the internal temperature, so that A/C is on; the temperature then
% drops, so that the system switches to heat.
%
% See also HVACSim>RHS, HVACSim>Controller

% Controller parameters
useFuzzy = true;
useSimple = true;
tDB  = 2; % Deadband (deg-K), for non-fuzzy controller

% Simulation parameters
dur  = 8*3600;
dT   = 5; % Time step (sec)
rho  = 1.2; % Atmospheric density (kg/m^3)
n    = ceil(dur/dT)+1;
iS   = ceil(n/2);

% Uncomment the chosen example. The external temperature is a function of
% time with a step change halfway through.

% A/C example
%%{
tSet = 297; % Set point temperature (deg-K)
tI   = tSet+3; % Initial internal temperature (deg-K)
delT = 10; % Celsius
tE   = [ones(1,iS)*(tI + delT) ones(1,n-iS)*(tI - delT) ];
%}

% Heat example
%%{
tSet = 294; % Set point temperature (deg-K)
tI   = tSet-10; % Initial internal temperature (deg-K)
tE   = [ones(1,iS)*(tI - 20) ones(1,n-iS)*(tI - 10) ];
%}

% HVAC system heat capacity, W
qMax = 1000;

% House dimensions
l    = 10; % m
w    = 10; % m
h    = 6;  % m
v    = l*w*h; % House volume
m    = rho*v; % Air mass (kg)
cP   = 1006; % Specific heat (J/kg-K)
A    = l*w + h*(w+l)*2; % House surface area (m^2)

% Data structure for the simulation
d    = struct('k',1/13,'A',A,'cP',cP,'q',0,'tE',tE,'m',m);
q    = 0; % Initial heat flux

% Initialize the fuzzy controller
if( useFuzzy )
  if useSimple
    dFuzzy = HVACSimplestFuzzyController('initialize',qMax);
  else
    dFuzzy = HVACFuzzyController('initialize',1.25*qMax);
  end
end

xP = zeros(6,n);
h_w = waitbar(0,'HVACSim');
for k = 1:n
  if( useFuzzy)
    if useSimple
      q = HVACSimplestFuzzyController('update',tI,tSet,dFuzzy);
    else
      q = HVACFuzzyController('update',tE(k),tI,tSet,dFuzzy);
    end
  else
    q = Controller(tI,tSet,tDB,q,qMax);
  end

  % Assign thermal flux to AC or heat
  if( q > 0 )
    d.qH = q;
    d.qC = 0;
  elseif( q < 0 )
    d.qC = -q;
    d.qH = 0;
  else
    d.qC = 0;
    d.qH = 0;
  end 
  d.tE    = tE(k);
  [~,qL]  = RHS(tI,0,d);
  xP(:,k) = [q;d.qH;d.qC;qL;tE(k);tI];
  tI      = RungeKutta(@RHS,0,tI,dT,d);
  waitbar(k/n,h_w,'HVACSim');
end
close(h_w);
t = (0:n-1)*dT;

xP(5:6,:) = (xP(5:6,:) - 273)*9/5+32; % Plot in Farenheit

yL = {'q (W)' 'q_h (W)' 'q_c (W)' 'q_l (W)','T_e (F)' 'T_i (F)' };
if useFuzzy
  str = 'Home - Fuzzy Controller';
else
  str = 'Home - Standard Controller';
end
TimeHistory(t,xP,yL,str);
x = get(gca,'xLim');
line(x,([tSet;tSet] - 273)*9/5+32,'color','r');

function [dT,qL] = RHS(~,tI,d)
%% Simulation right hand side (dynamics)
% Model the changing internal temperature of the house given the HVAC
% output and the external temperature.
%
% [dT,qL] = RHS(~,tI,d)
%
% dT: change in internal temperature
% qL: heat load on the house from outside

qL = d.k*d.A*(d.tE-tI);
dT = (qL + d.qH - d.qC)/(d.cP*d.m);

end

function q = Controller(t,tSet,tDB,q,qMax)
%% Non-fuzzy Controller with hysteresis
% Typical crisp controller with a deadband and hysteresis
%
% q = Controller(t,tSet,tDB,q,qMax)

if( q < 0 )
  if( t < tSet - 0.9*tDB)
    q = 0;
  end
elseif( q > 0 )
  if( t > tSet + 0.9*tDB)
    q = 0;
  end
else
  if( abs(t - tSet) > tDB )
    if( t > tSet)
      q = -qMax;
    elseif ( t < tSet )
      q = qMax;
    end
  end
end

end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
