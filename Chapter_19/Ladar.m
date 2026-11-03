function [rho,c] = Ladar(hMap,rL,xMap,angleSamp,nSamp)

%% Ladar function Generate the range measurements
% Assume an xy-scan with nSamp per axis and angleSamp between samples
% It uses a small angle approximation for the scanning.
%
%% Form:
%   [rho,c] = Ladar(hMap,rL,xMap,angleSamp,nSamp)
%% Description
%
%   Type Ladar for a demo.
%
%% Inputs
%   hMap      (n,n) Height map
%   rL        (3,1) Lander location
%   xMap      (1,:) X and Y coordinates
%   angleSamp (1,1) Angle change per sample
%   nSamp     (1,1) Number of samples
%% Outputs
%   rho       (1,n) Range (m)
%   c         (2,:) Indices from hMap
%   

if( nargin < 1 )
  angleSamp = 0.001;
  nSamp     = 2;
  file      = "Site01_final_adj_5mpp_surf.tif";
  [z,xY]    = LoadNASADEM( file, 0.1, 200:300 );
  rL        = [0;0;1200];
  Ladar(z,rL,xY,angleSamp,nSamp);
  return
end

angle = angleSamp*[-nSamp:-1 0 1:nSamp];

% Use a small angle approximation
i = 1;
m = 2*nSamp+1;
p = zeros(2,m*m);
for j = 1:m
  thetaX = angle(j);
  for k = 1:m
    thetaY = angle(k);
    u        = Unit([-thetaY;thetaX;1]);
    p(:,i)   = rL(3)*u(1:2) + rL(1:2);
    i        = i + 1;
  end
end
hS       = interp2(xMap(1,:),xMap(2,:),hMap,p(1,:),p(2,:));
p        = [p;hS];
rho      = Mag(rL-p);

% Make into a square
rho = reshape(rho,m,m);

% Plot
if( nargout < 1 )
  yL = {'Range' 'X Index' 'Y Index'};
  NewFig('Measurement')
  surf(rho);
  zlabel('z (m)')
  xlabel('x (m)')
  ylabel('y (m)')
  title('Scan', 'Interpreter', 'none');
  colorbar

  NewFig('Surface');
  surf(xMap(1,:),xMap(2,:),hMap)
  zlabel('z (m)')
  xlabel('x (m)')
  ylabel('y (m)')
  title('Surface', 'Interpreter', 'none');
  hold on
  plot3(rL(1),rL(2),rL(3),'o','linewidth',2,'MarkerFaceColor',[1 0 0]);

  colorbar
  grid on
  rotate3d on

  clear rho
end



