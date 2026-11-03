%%  Lunar landing
%--------------------------------------------------------------------------

% Constants
rMoon         = Constant('equatorial radius moon');
muMoon        = Constant('mu moon');
gEarth        = Constant('accel grav mks');
muEarth       = Constant('mu earth');
kMToM         = 1000;
mToS          = 60;
gMoon         = muMoon*1000/rMoon^2;
thrustAR40    = 6000*4.448; % N
nSteps        = 1000;
nAccel        = 1.38;


% hDescent is the altitude from which you begin the descent leg. Allow for
% the highest point on dark side, which is 6.5 km higher than Mons Huygens
% (altitude 4.7 km), and allow a margin of 0.3 km
hDescent     	= 6.5 + 4.7 + 0.3; 
uDescent          = sqrt(muMoon/rMoon);


% Compute the landing trajectory
[beta, tLand] = BilinearTangentLaw( uDescent*1000, gMoon,  nAccel*gMoon, hDescent*1000, nSteps );

%% Simulate the landing
% beta is the thrust vector angle from the horizontal. We need to flip the
% results for a landing as the default is an ascent.

% Flip for a landing
beta = fliplr(beta);
dT   = tLand(2) - tLand(1);

% Size the plotting array
n   = length(beta);
xP  = zeros(2,n);

% Initial state
x   = [0;hDescent*1000;-uDescent*1000;0]; % m and m/s

%% Simulate
for k = 1:n
  xP(:,k)	= x(1:2);
  x       = RK4('RHSPlanetTakeoff',x,dT,0,gMoon*nAccel,gMoon,beta(k));
end

% Titles for plots
s1 = 'Lunar Trajectory';
s2 = 'Landing States';

Plot2D(xP(1,:),xP(2,:),'x (m)','y (m)',s1);

% Annotate the plot
hold on
plot(xP(1,1),xP(2,1),'ko','MarkerFaceColor','k')
plot(xP(1,end),0,'rd','MarkerFaceColor','k')
xLim = get(gca,'xlim');
line(xLim,[hDescent;hDescent],'color','black')
legend('Trajectory','Initial Location','Final Location','Location','Best')
set(gca,'ylim',[0 xP(2,1)])

save("landingTrajectory.mat","xP")

