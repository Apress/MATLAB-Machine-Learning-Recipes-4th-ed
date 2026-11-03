%% Compute pixelmaps from yaw transformations
% Generates an image with subplots showing multiple rotated pixelmaps. 
% In the figure red are the original stars, and green the rotated stars.
%% See also:
% LoadHipparcos, PinholeCamera, YawPixelTransform

% Star catalog
[rA,dec] = LoadHipparcos( 6 );

% Camera properties
f = 50;
w = 5;

% Yaw angles to rotate
yaw = linspace(0,2*pi,13);

% Original pixels
%cDec = cos(dec);
%u    = [cos(rA).*cDec;sin(rA).*cDec;sin(dec)];
p    = PinholeCamera(rA,dec,f,w);

% Transformed pixels
pT   = YawPixelTransform( yaw, rA, dec, f, w );

% Draw
n = length(yaw);
m = ceil(n/4);

NewFigure( 'Snapshots' );
for k = 1:n
  subplot(m,4,k)
  plot(p(1,:),p(2,:),'o','LineWidth',2,...
                   'MarkerEdgeColor','r',...
                   'MarkerFaceColor','r',...
                   'MarkerSize',2)
  hold on
  plot(pT{k}(1,:),pT{k}(2,:),'o','LineWidth',2,...
                   'MarkerEdgeColor',[0.4 0.7 0.1],...
                   'MarkerFaceColor',[0.4 0.7 0.1],...
                   'MarkerSize',2)
  title(sprintf('%8.1f deg',yaw(k)*180/pi))
  grid on
  axis square
  axis(w/2*[-1 1 -1 1])
end
