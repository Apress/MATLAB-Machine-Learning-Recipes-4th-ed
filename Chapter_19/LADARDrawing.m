%% Draw a picture of the lander, DEM and beam

% Lander model
g = load('LLAV');
DrawCAD(g)

% Scale appropriately
h = 20;
w = 2;
v = [5.75 -1.13 2.5];
z = [w w -w -w]/2;
y = [-w w w -w]/2;

for k = 1:4
  v = [v;v(1)-h y(k),z(k)];
end

f = [1 2 3;1 3 4;1 4 5; 1 5 2];
patch('vertices',v,'faces',f,'facecolor',[1 0 0],...
      'edgecolor',[1 0 0],'facealpha',0.2,'edgealpha',0);


z = LoadNASADEM( "Site07_final_adj_5mpp_surf.tif");

DrawDEM(z);
