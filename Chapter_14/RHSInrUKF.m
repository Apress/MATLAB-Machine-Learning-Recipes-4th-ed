function f = RHSInrUKF( ~, x, d )

%% Right-hand-side for a rigid body.
%   t is not used. This is compatible with RK4 and RK45.
%--------------------------------------------------------------------------
%   Form:
%   f = RHSInrUKF( ~, x, d )
%--------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   t         (1,1)  Time (not used)
%   x         (3,1)  Rates
%   d         (1,1)  Data structure
%                    .w   (1,1) [Ixx Iyy Izz Ixy Ixz Iyz]
%                    .u   (3,1) Input
%
%   -------
%   Outputs
%   -------
%   f         (3,1)  State derivative
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%   Copyright (c) 2006 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%--------------------------------------------------------------------------t
%   2019.1 Added default data structure outpu
%--------------------------------------------------------------------------

if( nargin < 1 )
  f = struct('w',[1 2 3 0 0 0],'u',[1;2;3]);
  return;
end

inr = [d.w(1) d.w(4) d.w(5);d.w(4) d.w(2) d.w(6);d.w(5) d.w(6) d.w(3)];

f   = inr\(d.u - Cross(x,inr*x));


%--------------------------------------
% $Date$
% $Id: 17b2a67d4d5d674c65757404017ab3cb53ae3aa3 $

