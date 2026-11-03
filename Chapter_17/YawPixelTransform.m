%% Transform star angles by yaw
% Computes the pixelmap with PinholeCamera. yaw is about +z
%
%% Form:
%  pT = YawPixelTransform(yaw,rA,dec,w,f)
%
%% Inputs
%   yaw      (1,:) Yaw angle
%   rA       (:,1) Right ascension of stars from catalog
%   dec      (:,1) Declination  of stars from catalog
%   f        (1,1) Focal length
%   w        (1,1) Length and width, the same units as f
%
%% Outputs
%   pT       (2,:) Pixels
%
%% See also
% PinholeCamera

function pT = YawPixelTransform(yaw,rA,dec,f,w)

n  = length(yaw);
pT = cell(n,1);

cDec = cos(dec);
u    = [cos(rA).*cDec;sin(rA).*cDec;sin(dec)];

for k = 1:n
  c     = cos(yaw(k));
  s     = sin(yaw(k));
  m     = [c s 0;-s c 0;0 0 1]; % about z axis
  uT    = m*u;
  rAT   = atan2(uT(2,:),uT(1,:));
  decT  = asin(uT(3,:));
  pT{k} = PinholeCamera(rAT,decT,f,w);
end

%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
