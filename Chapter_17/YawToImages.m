%% Generate star images from rotations
% This will delete the existing pictures in YawImages, or create the folder
% if it does not exist. 
%
%% Form:
%   YawToImages( yaw, rA, dec, f, w )
%
%% Inputs
%   yaw      (1,:) Yaw angle
%   rA       (:,1) Right ascension of stars from catalog
%   dec      (:,1) Declination  of stars from catalog
%   f        (1,1) Focal length
%   w        (1,1) Length and width, the same units as f
%
%% Outputs
%  None
%% See also
% YawPixelTransform, LoadHipparcos, NewFigure

function YawToImages( yaw, rA, dec, f, w )

% Demo
if( nargin < 1 )
  [rA,dec] = LoadHipparcos( 6 );
  n        = 50;
  yaw      = linspace(0,2*pi,n+1);
  YawToImages( yaw(1:n), rA, dec, 64, (64/50)*5 );
  return
end

% Yaw transformed pixels
pT   = YawPixelTransform( yaw, rA, dec, f, w );

% Set up the directory
if ~exist('YawImages','dir')
  warning('Are you in the right folder? No YawImages')
  mkdir('./','YawImages')
end
cd YawImages
delete *.jpg % Starting from scratch so delete existing images

n = length(yaw);
NewFigure('StarImage');

for k = 1:n
  s = sprintf('Yaw %8.2f deg: %d of %d',yaw(k)*180/pi,k,n);
  plot(pT{k}(1,:),pT{k}(2,:),'o',...
  'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',16)
  title(s);
  axis off
  axis square
  set(gcf,'Color',[1 1 1]);
  x = frame2im(getframe(gcf));
  s = sprintf('YawImage%d.jpg',k);
  x = imresize(x,[f f]);
  imwrite(rgb2gray(x),s);
  pause(0.4);
end
close(gcf);

save('Label','yaw')


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
