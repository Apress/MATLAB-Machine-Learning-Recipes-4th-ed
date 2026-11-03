function [z,zMax] = GetDEM(file,c,w)

if( nargin < 1 )
  GetDEM("Site07_final_adj_5mpp_surf.tif",[1600;1600],100);
  return
end

z       = imread(file); % Height in meters

rangeX  = ceil(c(1)-w/2):floor(c(1)+w/2);
rangeY  = ceil(c(2)-w/2):floor(c(2)+w/2);

z       = z(rangeX,rangeY);
zMax    = max(max(z));

[~,name] = fileparts(file);

NewFig(name);
mesh(z)
zlabel('z (m)')
xlabel('x (m)')
ylabel('y (m)')
title(sprintf('%s Surface c = [%6.1f %6.1f] m',name,c), 'Interpreter', 'none');

colorbar
grid on
rotate3d on