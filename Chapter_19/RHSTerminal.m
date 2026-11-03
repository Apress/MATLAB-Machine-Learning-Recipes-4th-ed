function xDot = RHSTerminal(x,~,a,g)

% Hit the ground
if( x(3) <= 0 )
  g = 0;
end

xDot = [x(4:6);a - [0;0;g]];

end