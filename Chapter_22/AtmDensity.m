%% ATMDENSITY Modified exponential atmosphere
%% Form
%  rho = AtmDensity( h );
%
%% Description
% Modified exponential atmosphere. Suitable up to 100 km altitude.
%
% Type AtmDensity for a demo.
%
%% Inputs
%  h       (1,:) Altitude (m)
%
%% Outputs
%  rho     (1,:) Density (kg/m^3)
%% See also
% AtmDensity>Demo

function rho = AtmDensity( h )

% Demo
if( nargin < 1 )
  Demo
  return
end

h   = 0.001*h; % Convert to km
rho = 1.225*exp(-0.0817*h.^1.15); % This provides a slightly better fit

% Plot results
if( nargout == 0 )
  PlotSet(h,rho,'x label','Altitude (km)','y label', 'Density (kg/m^3)',...
          'figure title', 'Density', 'plot title','Density','plot type','ylog');
  clear rho
end

%% AtmDensity>Demo
function Demo
% Plot the density from 0 to 100 km
AtmDensity(linspace(0,100000));


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
