%% Read in a Digital Elevation Map
% The file is a tif file
%
%% Form:
%   [z,xY,info] = LoadNASADEM( file, s, range )
%% Description
%   The DEM is a digital elevation map.
%
%   Type LoadNASADEM for a demo.
%
%% Inputs
%   file  (1,:) tif file name
%   s     (2,1) Scale for the coordinates
%   range (1,;) Range to use

%% Outputs
%   z       (:,:) Height
%   xY      (1,:) XY coordinates
%   info    (.)   Information on the file
%   
%% Reference
%   Michael Kenneth Barker, "High-Resolution LOLA Topography for Lunar 
%   South Pole Sites."
%   https://pgda.gsfc.nasa.gov/products/78

function [z,xY,info] = LoadNASADEM( file, s, range )

if( nargin < 1 )
  c = [0;0];
  s = 0.1;
  LoadNASADEM( "Site01_final_adj_5mpp_surf.tif", s, 200:300 );
  return
end

info  = imfinfo(file);

if( nargin < 2 )
  s = 5;
end

z     = imread(file); % Height in meters
if( nargin < 3 )
  [n,~] = size(z);
  range = 1:n;
end
z     = z(range,range);
[l,w] = size(z);
xY    = ([0:l-1;0:w-1] - [l;w]/2)*s;

if( nargout == 0 )
  [~,name] = fileparts(file);

  NewFig(name);
  mesh(z)
  zlabel('z (m)')
  xlabel('x (m)')
  ylabel('y (m)')
  title(sprintf('%s Surface ',name), 'Interpreter', 'none');

  colorbar
  grid on
  rotate3d on
  clear z
end
