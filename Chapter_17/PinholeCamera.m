%% PINHOLECAMERA Model a pinhole camera
% Return the points within the width of the sensor. z is normal to the focal plane
%
%% Form:
%   [p,id] = PinholeCamera( rA, dec, f, w )
%
%% Inputs
%   rA       (:,1) Right ascension
%   dec      (:,1) Declination
%   f        (1,1) Focal length
%   w        (1,1) Length and width the same units as f
%
%% Outputs
%   p       (2,:) Pixels
%   id      (1,:) Index of returned pixels from original array

function [p,id] = PinholeCamera( rA, dec, f, w )

if( nargin < 1 )
  [rA,dec] = LoadHipparcos( 6 );
  PinholeCamera( rA, dec, 50, 5 );
  return
end

cDec = cos(dec);
p    = f*[cos(rA).*cDec;sin(rA).*cDec];
j    = sin(dec)>0; % front facing
k    = ((abs(p(1,:)) <= w/2) & (abs(p(2,:)) <= w/2)); % within width
id   = find(j & k);
p    = p(:,id);

% Plot the camera output
if( nargout == 0 )
  NewFigure( 'Focal Plane' );
  v      = 0.5*w*[1 1 0;1 -1 0;-1 -1 0;-1 1 0];
  v(:,3) = -f;
  patch('faces',[1 2 3 4], 'Vertices', v,'facecolor',...
    [0 0 1],'facealpha',0.2);
  hold on
  rotate3d on
  view([1 1 1]);
  line([0 0],[0 0],[0 -f],'linewidth',2);
  text(0,0,0.1*f,'Pinhole')
  p(3,:) = -f;
  plot3(p(1,:),p(2,:),p(3,:),'o','LineWidth',2,...
                       'MarkerEdgeColor','r',...
                       'MarkerFaceColor','r',...
                       'MarkerSize',5)
  grid on
  CelestialSphere( rA(id), dec(id) )
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
