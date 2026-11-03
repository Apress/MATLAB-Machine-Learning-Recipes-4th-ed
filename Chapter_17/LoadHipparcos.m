%% LOADHIPPARCOS Load a catalog and reduce it based on visual magnitude.
% Includes a demo of the Hipparcos catalog. The figure will be generated if
% called with no outputs or if the doPlot flag is true.
%% Form:
%   [rA,dec,vM] = LoadHipparcos( visualMagnitude )
%
%% Inputs
%   visualMagnitude (1,1)  Visual magnitude limit
%
%% Outputs
%   rA       (:,1) Right ascension
%   dec      (:,1) Declination
%   vM       (:,1) Visual magnitude

function [rA,dec,vM] = LoadHipparcos( visualMagnitude )

if( nargin < 1 )
  visualMagnitude = 6;
end

catalog = load( 'Hipparcos' );

k      = find( catalog.vM <= visualMagnitude);
rA     = catalog.rA(k);
dec    = catalog.dec(k);
vM     = catalog.vM(k);
nStars = length(catalog.rA);

% Plot information about the catalog
if( nargout == 0 )
  NewFigure( 'Catalog' );
  subplot(2,1,1);
  plot( rA*180/pi, dec*180/pi, '.' )
  set( gca, 'xlim', [0 360], 'ylim', [-90 90] );
  xlabel( 'Right Ascension (deg)' );
  ylabel( 'Declination (deg)' );
  title( sprintf( 'Hipparcos Star Catalog: %4.0f of %5.0f of the stars in the catalog',length(k),nStars ) );
  grid on;
  
  x = linspace(min(vM),max(vM),20);
  j = zeros(1,20);
  for k = 1:20
    j(k) = length(find( vM <= x(k) ));
  end

  subplot(2,1,2)
  semilogy( x, j )
  hold on
  semilogy( visualMagnitude, length(find( vM < visualMagnitude )), 'r*' )
  xlabel( 'Visual Magnitude' );
  ylabel( 'Number' );
  title( 'Number of Stars less than a Visual Magnitude' );
  grid on
  clear rA
end


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
