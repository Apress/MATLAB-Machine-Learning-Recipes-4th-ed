%% Simulate 3D attitude transformations
% Rotate the stars by an arbitary quaternion and return the pixelmap. z is
% normal to the focal plane. In the figure red are the original stars, and
% green the rotated stars.
%% Form:
%   [rAT, decT, pT, p] = AttitudeSim( q, rA, dec, f, w )
%
%% Inputs
%   q        (4,1) Quaternion from ECI to body
%   rA       (:,1) Right ascension
%   dec      (:,1) Declination
%   f        (1,1) Focal length
%   w        (1,1) Length and width the same units as f
%
%% Outputs
%   rAT      (:,1) Right ascension
%   decT     (:,1) Declination
%   pT       (:,1) Transformed pixels
%   p        (:,1) Original pixels

function [rAT, decT, pT, p] = AttitudeSim( q, rA, dec, f, w )

% Demo
if( nargin < 1 )
  [rA,dec] = LoadHipparcos( 6 );
  ang      = pi/6; % theta/2
  q        = [cos(ang);0;0;sin(ang)];
  AttitudeSim( q, rA, dec, 50, 5 );
  return
end

cDec = cos(dec);
u    = [cos(rA).*cDec;sin(rA).*cDec;sin(dec)];

uT   = QForm(q,u); % rotated unit vectors

rAT  = atan2(uT(2,:),uT(1,:));
decT = asin(uT(3,:));

% Compute pixels if w and f are entered
if( nargin > 3 )
  p  = PinholeCamera(rA,dec,f,w);
  pT = PinholeCamera(rAT,decT,f,w);
end

% Plot star locations in the pixel frame
if( nargout == 0 )
  if( nargin > 3 )
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
    plot3([0 p(1,1)],[0 p(2,1)],[-f p(3,1)],'r')
    pT(3,:) = -f;
    plot3(pT(1,:),pT(2,:),pT(3,:),'o','LineWidth',2,...
                       'MarkerEdgeColor','g',...
                       'MarkerFaceColor','g',...
                       'MarkerSize',5)
    plot3([0 pT(1,1)],[0 pT(2,1)],[-f pT(3,1)],'g')
    grid on
  end
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.

