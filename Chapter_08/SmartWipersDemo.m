%% Demonstrates a Fuzzy Logic Control System for windshield wipers.
% This demonstrates a fuzzy logic control system
%
%% See also
% SmartWipersSystem, BuildFuzzySystem, FuzzyPlot, FuzzyInference

%% Initialize
% Create the system
SmartWipers = SmartWipersSystem;

%% Plot the fuzzy variables
FuzzyPlot( SmartWipers.input(1) );
FuzzyPlot( SmartWipers.input(2) );
FuzzyPlot( SmartWipers.output(1) );
FuzzyPlot( SmartWipers.output(2) );

%% Plot the rule base

PrintFuzzyRules( SmartWipers )

% Generate regularly space arrays in the 2 inputs
n = 30; % Number of samples
x = linspace(SmartWipers.input(1).range(1),SmartWipers.input(1).range(2),n);
y = linspace(SmartWipers.input(2).range(1),SmartWipers.input(2).range(2),n);

% Perform fuzzy inference over the input range
z1 = zeros(n,n);
z2 = zeros(n,n);
for k = 1:n
  for j = 1:n  
    temp = FuzzyInference([x(k),y(j)], SmartWipers);
    z1(k,j) = temp(1);
    z2(k,j) = temp(2);
  end
end

% Plot the inputs range
PlotSet(1:n,[x;y],'x label','Input','y label',{'Wetness','Intensity'},...
        'figure title','Inputs','Plot Title',{'Wetness','Intensity'})

% Plot the outputs as surfaces
NewFigure('Wiper Speed from Fuzzy Logic');
surf(x,y,z1)
xlabel('Raindrop Wetness')
ylabel('Droplet Frequency')
zlabel('Wiper Speed')
colorbar

NewFigure('Wiper Interval from Fuzzy Logic');
surf(x,y,z2)
xlabel('Raindrop Wetness')
ylabel('Droplet Frequency')
zlabel('Wiper Interval')
view([142.5 30])
colorbar

%% Run it

% Invent some wetness and intensity data for a brief rainstorm
wetness = [linspace(0,70) 70+1*randn(1,30) linspace(70,0,20) 10*rand(1,30)];
intensity = [linspace(0,sqrt(150),80).^2 160+10*randn(1,50) linspace(sqrt(140),0,20).^2 20*rand(1,30)];
t = 1:length(wetness);

data = [];
for k = 1:length(wetness)
  data(:,k) = FuzzyInference([wetness(k),intensity(j)], SmartWipers);
end

PlotSet(t,[wetness;intensity],'ylabel',{'Rain Wetness','Rain Intensity'})
PlotSet(t,data,'ylabel',{'Wiper Speed' 'Wiper Interval'})


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
