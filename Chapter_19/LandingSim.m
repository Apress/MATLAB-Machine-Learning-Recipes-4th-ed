%% Lunar landing terminal control
% z is vertical

%% Setup up the simulation and controller
g       = 1.6231; % m/s^2

tEnd    = 50; % End time (s)
dT      = 0.001; % Time step (s)
n       = ceil(tEnd/dT); % Number of step
xP      = zeros(10,n); % Plotting array
x       = [0;0;100;0;0;0]; % [x;y;z;v_x;v_y;v_z] (m,m/s)

% For the control system xT is the target
d      = struct('mode',0,'g',g,'h',x(3),'xT',[10;5;100;0;0;0]);

%% Simulations
for k = 1:n
  [a,d]   = LandingControl(x,d);
  xP(:,k) = [x;a;d.mode];
  x       = RK4(@RHSTerminal,x,dT,0,a,g);
end

%% Plotting
t   = (0:n-1)*dT;
yL  = {'x (m)'       'y (m)',      'z (m)'  ...
       'v_x (m/s)'   'v_y (m/s)',  'v_z (m/s)' ...
       'a_x (m/s^2)' 'a_y (m/s^2)' 'a_z (m/s^2)' 'Mode'};

k   = 1:3;
TimeHistory(t,xP(k,:),yL(k),'Landing Position');
k   = 4:6;
TimeHistory(t,xP(k,:),yL(k),'Landing Velocity');
k = 7:10;
TimeHistory(t,xP(k,:),yL(k),'Landing Control Acceleration');
set(gca,'YTickLabel',{'PD' ' ' 'PD/BB'})

% 3D Plot
Plot3D(xP(1:3,:),yL{1},yL{2},yL{3},'Landing 3D');
xL = get(gca,'xlim');
yL = get(gca,'yLim');
v  = 5*[xL(1) yL(1) 0;...
      xL(2) yL(1) 0;...
      xL(2) yL(2) 0;...
      xL(1) yL(2) 0];
patch('faces',[1 2 3 4],'vertices',v,'facecolor',[0.7 0.7 0.7])
view([-1 -1 2]);

save('Trajectory','xP');