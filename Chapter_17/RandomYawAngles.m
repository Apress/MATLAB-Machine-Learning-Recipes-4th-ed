%% Generate images at random yaw angles

[rA,dec] = LoadHipparcos( 6 );
n        = 1000;
yaw      = rand(1,n)*2*pi;
YawToImages( yaw, rA, dec, 64, (64/50)*5 );


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
