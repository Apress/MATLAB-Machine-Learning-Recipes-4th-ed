%% Draw a Digital Elevation Map
% The file is a tif file
%
%% Form:
%   z = DrawDEM(file)
%% Description
%   The DEM is a digital elevation map.
%
%   Type DrawDEM for a demo.
%
%% Inputs
%   file    (1,:) tif file name
%% Outputs
%   None
%   
%% Reference
%   Michael Kenneth Barker, "High-Resolution LOLA Topography for Lunar 
%   South Pole Sites."
%   https://pgda.gsfc.nasa.gov/products/78
function z = DrawDEM(file)

if( nargin < 1 )
  DrawDEM("Site07_final_adj_5mpp_surf.tif");
  return
end

z     = imread(file); % Height in meters

[~,name] = fileparts(file);

NewFig(name);
mesh(z)
zlabel('z (m)')
xlabel('x (m)')
ylabel('y (m)')
title(sprintf('%s Surface',name), 'Interpreter', 'none');

colorbar
grid on
rotate3d on