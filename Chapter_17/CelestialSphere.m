%% Draw stars as points on a 3D celestial sphere
%
%% Form:
%   CelestialSphere( rA, dec )
%
%% Inputs
%   rA       (:,1) Right ascension
%   dec      (:,1) Declination
%
%% Outputs
%   None

function CelestialSphere( rA, dec )

% Demo
if( nargin < 1 )
  [rA,dec] = LoadHipparcos( 6 );
  CelestialSphere( rA, dec );
  return
end

cDec = cos(dec);
u    = [cos(rA).*cDec;sin(rA).*cDec;sin(dec)];

NewFigure( 'Celestrial Sphere' );

sphere(120);
colormap('gray');
axis equal
alpha 0.1
shading interp
hold on
plot3(u(1,:),u(2,:),u(3,:),'.');
xlabel('x');
ylabel('y');
zlabel('z');


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
