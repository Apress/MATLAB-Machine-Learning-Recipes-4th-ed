%% Fuzzy logic control system for HVAC
% This demonstrates a fuzzy logic control system. There are two inputs: the
% external temperature and the delta temperature from the setpoint. There
% are two outputs: the mode of the HVAC (A/C or heating) and output
% magnitude. Temperatures for the variables are in C. Simulation input is in K.
%
%% Form:
%  d     = HVACFuzzyController('initialize',qMax)
%  [d,q] = HVACFuzzyController('update',tE,t,tSet,d)
%
%% Inputs
%  mode (1,:) 'initialize' 'update
%  tE   (1,1) Outside Temperature (K)
%  tI   (1,1) Inside Temperature (K)
%  tSet (1,1) Set point (K)
%  d    (.)   Fuzzy logic data structure
%
%% Outputs
%  q    (1,1) Heat output
%
%% See also
% BuildFuzzySystem, FuzzyPlot, FuzzyInference
%

function [q,cat] = HVACFuzzyController(mode,tE,tI,tSet,d)

if( nargin < 1)
  Demo;
  return
end

%% Initialize
% Create the system
switch mode
  case 'initialize'
    if nargin<2
      qMax = 1000;
    else 
      qMax = tE;
    end
    oP = {qMax*[0 0 0.2 0.2] qMax*[0.2 0.3 0.5 0.6] qMax*[0.5 0.7 1.01 1.01]};

    d = BuildFuzzySystem(...
              'id',1,...
              'input comp',{'Cold'  'Temperate' 'Hot'} ,...
              'input type', {@TrapezoidMF  @TrapezoidMF @TrapezoidMF} ,...
              'input params',{[-11 -11 50 70] [60 70 75 80] [70 80 111 111]},...
              'input range',[-10 110],...
              'input name','Ext Temp (F)',...
              'id',2,...
              'input comp',{'Chilly'  'OK'  'Warm'} ,...
              'input type', {@TrapezoidMF  @TrapezoidMF @TrapezoidMF} ,...
              'input params',{[-21 -21 -8 0] [-5 -1 1 5] [0 8 21 21]},...
              'input range',[-20 20],...
              'input name','Delta-Temp (F)',...
              'id',1,...
              'output comp',{'AC' 'Off' 'Heat'},...
              'output type',{@TrapezoidMF  @TrapezoidMF @TrapezoidMF},...
              'output params',{[-1.1 -1.1 -0.5 0] [-0.5 0 0 0.5] [0 0.5 1.1 1.1]},...
              'output name','Mode',...
              'output range',[-1 1],...
              'id',2,...
              'output comp',{'Zero'  'Low'  'High'},...
              'output type',{@TrapezoidMF  @TrapezoidMF  @TrapezoidMF},...
              'output params',oP,...
              'output name','Output',...
              'output range',[0 qMax],...
              'id',1,... % Cold and Too cold, Heat/high
              'rule input',{'Cold','Chilly'},...
              'rule output',{'Heat','High'},...
              'rule operator',@FuzzyAND,...
              'id',2,... % temperate and too cold, Heat/low
              'rule input',{'Temperate','Chilly'},...
              'rule output',{'Heat','Low'},...
              'rule operator',@FuzzyAND,...
              'id',3,... % Hot and too cold, AC/off
              'rule input',{'Hot','Chilly'},...
              'rule output',{'Off','Zero'},...
              'rule operator',@FuzzyAND,...
              'id',4,... % Cold and OK, Heat/zero
              'rule input',{'Cold','OK'},...
              'rule output',{'Off','Zero'},...
              'rule operator',@FuzzyAND,...
              'id',5,... % temperate and OK, off/off
              'rule input',{'Temperate','OK'},...
              'rule output',{'Off','Zero'},...
              'rule operator',@FuzzyAND,...
              'id',6,... % Hot and OK, AC/off
              'rule input',{'Hot','OK'},...
              'rule output',{'Off','Zero'},...
              'rule operator',@FuzzyAND,...
              'id',7,... % Cold and too hot, Heat/off
              'rule input',[1 3],...
              'rule output',[2 1],...
              'rule operator',@FuzzyAND,...
              'id',8,... % temperate and too hot, AC/low
              'rule input',[2 3],...
              'rule output',[1 2],...
              'rule operator',@FuzzyAND,...
              'id',9,... % Hot and too hot, AC/high
              'rule input',[3 3],...
              'rule output',[1 3],...
              'rule operator',@FuzzyAND,...
              'implicate',@ScaleIMP,...
              'aggregate','sum',...
              'defuzzify',@CentroidDF);
    q = d;
    cat = [];
  case 'update'
    kToC  = 273;
    delta = (tI - tSet)*9/5;    % in K
    tF    = (tE-kToC)*9/5 + 32; % in F
    % expect internal temperature to be within specified range
    if tF>d.input(1).range(2)
      tF = d.input(1).range(2) - eps;
    elseif tF<d.input(1).range(1)
      tF = d.input(1).range(1) + eps;
    end
    % limit delta temperature range
    if delta>d.input(2).range(2)
      delta = d.input(2).range(2) - eps;
    elseif tF<d.input(2).range(1)
      delta = d.input(2).range(1) + eps;
    end
    [cat,data] = FuzzyInference([tF;delta], d);
      
    mode = sign(cat(1));
    if abs(cat(1))<0.01
      mode = 0;
    end
    q = mode*cat(2);
  
end

%% Demonstrate the controller
function Demo

d = HVACFuzzyController('initialize');

% Plot the fuzzy variables
FuzzyPlot( d.input(1) );
FuzzyPlot( d.input(2) );
FuzzyPlot( d.output(1) );
FuzzyPlot( d.output(2) );

PrintFuzzyRules( d )

% differentiate btwn internal and external temp
t = linspace(d.input(1).range(1)+1e-12,d.input(1).range(2)-1e-12,51);
t_K = 5/9*(t-32)+273;  % convert input from C to K
tSet = 297;  % example setpoint (K)
delta = linspace(d.input(2).range(1)+1e-12,d.input(2).range(2)-1e-12,31);
q = zeros(length(delta),length(t_K));
mode = zeros(length(delta),length(t_K));
val = zeros(length(delta),length(t_K));
for k = 1:length(t)
  for j = 1:length(delta)
    [q(j,k),cat] = HVACFuzzyController('update',t_K(k),tSet+5/9*delta(j),tSet,d);
    mode(j,k) = cat(1);
    val(j,k) = cat(2);
  end
end

NewFigure('HVAC Output from Fuzzy Logic');
surf(t,delta,q)
xlabel('Outside Temperature (F)')
ylabel('Delta (F)')
zlabel('HVAC Output (W)')
colorbar
set(gca,'ydir','reverse')

NewFigure('HVAC Mode from Fuzzy Logic');
surf(t,delta,mode)
xlabel('Temperature (F)')
ylabel('Delta (F)')
zlabel('HVAC Mode')
colorbar
set(gca,'ydir','reverse')

NewFigure('HVAC Value from Fuzzy Logic');
surf(t,delta,val)
xlabel('Temperature (F)')
ylabel('Delta (F)')
zlabel('HVAC Value (W)')
colorbar
set(gca,'ydir','reverse')

tSet = 297;
tI   = tSet+5;
Q = zeros(size(t));
for k = 1:length(t)
  Q(k) = HVACFuzzyController('update',t_K(k),tSet+5,tSet,d);
end

PlotSet(t_K,Q,'x label','T_e (K)','y label','Q (W)','plot title','Fuzzy HVAC');
y = get(gca,'ylim');
line(tSet*[1;1],y,'color','r')
line(tI*[1;1],y,'color','g')

tE = 280;
tSet = 294;
Q = zeros(size(delta));
for k = 1:length(delta)
  Q(k) = HVACFuzzyController('update',tE,tSet+delta(k)*5/9,tSet,d);
end
PlotSet(delta,Q,'x label','\Delta T (F)','y label','Q (W)',...
  'figure title','Fuzzy HVAC','plot title',sprintf('Te = %g F',(tE-273)*9/5+32));


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
