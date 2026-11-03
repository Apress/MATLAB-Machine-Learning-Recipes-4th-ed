%% Draw sites

c = [0;0];
z{1} = LoadNASADEM( "Site01_final_adj_5mpp_surf.tif", c);
z{2} = LoadNASADEM( "Site04_final_adj_5mpp_surf.tif", c);
z{3} = LoadNASADEM( "Site06_final_adj_5mpp_surf.tif", c);
z{4} = LoadNASADEM( "Site07_final_adj_5mpp_surf.tif", c);
s    = {'01' '04' '06' '07'};

  NewFig('Lunar South Pole Sites')
  for k = 1:4
    subplot(2,2,k)
    mesh(z{k})
    zlabel('z (m)')
    xlabel('x (m)')
    ylabel('y (m)')
    title(sprintf('Site %2s',s{k}));
    colorbar
    axis equal
    grid on
  end
