function d = UKFP( action, d, y )

%% Implement an Unscented Kalman Filter for parameter estimation.
% The filter uses numerical integration to propagate the state.
% The filter propagates sigma points, points computed from the
% state plus a function of the covariance matrix. For each parameter
% there are two sigma parameters. The current estimated state must be
% input each step.
%
% The filter appends internal data to the datastructure
%
% To initialize call
%
%   d = UKFP( 'initialize', d );
%
% To update
%
%   d = UKFP( 'update', d, y );
%--------------------------------------------------------------------------
%   Form:
%   d = UKFP( action, d, y )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   action    (1,:)  'initialize' or 'update'
%   d          (.)   UKFP data structure
%                    .rHSFun      (1,:) Name of RHS function
%                    .rHSFunData  (1,1) RHS function data structure
%                    .measFun     (1,:) Name of measurement function
%                    .measFunData (1,1) Measurement function data 
%                    .x           (:,1) State vector
%                    .p           (n,n) Covariance matrix for w   
%                    .rP          (n,n) Plant noise covariance 
%                    .rY          (m,m) Measurement noise covariance
%                    .alpha       (1,1) Scaling parameter (1e-4 to 1)
%                    .beta        (1,1) Scaling parameter (usually 2)
%                    .kappa       (1,1) Scaling parameter (usually 0) 
%                    .w           (n,1) Parameters      
%   y         (m,1)  Measurement vector
%
%   -------
%   Outputs
%   -------
%   d          (.)   UKFP data structure with the following appended
%                    .n           (1,1)   Twice the number of states + 1
%                    .y           (m,1)   Measurements based on the states
%                    .wA          {n}     Sigma points
%                    .wC          (1,n+1) Weights
%                    .wM          (1,n+1) Weights
%                    .gamma       (1,1)   Sigma points scaling parameter
%                    .lambda      (1,1)   Sigma points scaling parameter
%                    .pDD         (m,m)   Measurement covariance
%                    .pWD         (n,m)   Parameter, measurement cross
%                                         covariance
%                    .D           (n,2*n) Measurements at sigma points
%                    .dY          (n,1)   Residuals
%                    .L           (1,1)   Number of parameters
%
%--------------------------------------------------------------------------
%   References: Van der Merwe, R. and Wan, E., "Sigma-Point Kalman Filters for
%               Probabilistic Inference in Dynamic State-Space Models".
%               Matthew C. VanDyke, Jana L. Schwartz, Christopher D. Hall,
%               "UNSCENTED KALMAN FILTERING FOR SPACECRAFT ATTITUDE STATE AND
%               PARAMETER ESTIMATION,"AAS-04-115.
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2006 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------
%   Since version 9.
%--------------------------------------------------------------------------

switch action
  case 'initialize'
    d = Initialize( d );
  case 'update'
    d = Update( d, y );
end

%--------------------------------------------------------------------------
%   Initialize the UKF
%--------------------------------------------------------------------------
function d = Initialize( d )

d.L          = length(d.w);
d.lambda     = d.alpha^2*(d.L + d.kappa) - d.L;
d.gamma      = sqrt(d.L + d.lambda);
d.wC(1)      = d.lambda/(d.L + d.lambda) + (1 - d.alpha^2 + d.beta);
d.wM(1)      = d.lambda/(d.L + d.lambda);
d.n          = 2*d.L + 1;
for k = 2:d.n
  d.wC(k) = 1/(2*(d.L + d.lambda));
  d.wM(k) = d.wC(k);
end

d.wA         = zeros(d.L,d.n);
y            = feval( d.measFun, d.x, d.measFunData );
d.lY         = length(y);
d.D          = zeros(d.lY,d.n);

%--------------------------------------------------------------------------
%   Update the estimate and covariance
%--------------------------------------------------------------------------
function d = Update( d, y )

% Update the covariance
%----------------------
d.p = d.p + d.rP;

% Compute the sigma points
%-------------------------
d = SigmaPoints( d );

% Measurement
%------------
d.d = zeros(d.lY,1);

% We are computing the states, then the measurements
% for the parameters +/- 1 sigma
%--------------------------------------------------
for k = 1:d.n
  d.rHSFunData.w = d.wA(:,k);
  x              = RK4( d.rHSFun, d.x, d.dT, d.t, d.rHSFunData );
  d.D(:,k)       = feval( d.measFun, x, d.measFunData );
  d.d            = d.d + d.wM(k)*d.D(:,k);
end

d.pWD = zeros(d.L,d.lY);
d.pDD = d.rY;
for k = 1:d.n
  wD    = d.D(:,k) - d.d;
  d.pDD = d.pDD + d.wC(k)*(wD*wD');
  d.pWD = d.pWD + d.wC(k)*(d.wA(:,k) - d.w)*wD';
end

d.pDD = 0.5*(d.pDD + d.pDD');

% Incorporate the measurements
%-----------------------------
K     = d.pWD/d.pDD;
d.dY  = y - d.d;
d.w   = d.w + K*d.dY;
d.p   = d.p - K*d.pDD*K';
d.p   = 0.5*(d.p + d.p');

%--------------------------------------------------------------------------
%   Create the sigma points for the parameters
%--------------------------------------------------------------------------
function d = SigmaPoints( d )

n         = 2:(d.L+1);
m         = (d.L+2):(2*d.L + 1);
wM        = DupVect(d.w,length(d.w));
sqrtP     = real(sqrtm(d.p));
d.wA(:,1) = d.w;
d.wA(:,n) = wM + d.gamma*sqrtP;
d.wA(:,m) = wM - d.gamma*sqrtP;


%--------------------------------------
% $Date$
% $Id: 4cedf8614cbcfb9539865f42dd2ed8e4e73a530f $
