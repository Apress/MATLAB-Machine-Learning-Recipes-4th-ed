function [a,d] = LandingControl(x,d)

zeta  = 1.0;
omega = 0.3;
K     = omega^2;
tau   = 2*zeta/omega;

a     = [0;0;0];
xErr  = x - d.xT;
switch d.mode
  case 0
    if( Mag(xErr) < 0.01 )
      d.mode = 1;
    else
      a = -K*(xErr(1:3) + tau*xErr(4:6)) + [0;0;d.g];
    end

  case 1
    a(1:2) = -K*(xErr(1:2) + tau*xErr(4:5)) ;
    if( x(3) > d.h/2 )
      a(3) = 0;
    else
      a(3) = 2*d.g;
    end


end

