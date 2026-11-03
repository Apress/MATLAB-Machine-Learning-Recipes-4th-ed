%% Generate the measurements

angleSamp = 0.001;
nSamp     = 2;
file      = "Site01_final_adj_5mpp_surf.tif";
[h,xY]    = LoadNASADEM( file, 0.1, 200:300 );
rL0       = [0;0;1200];

x         = -40:10:40;
y         = -40:10:40;
z         = -40:10:40;


LoadNASADEM( file, 0.1, 200:300 );
hold on

p = 1;
n   = length(x);
rho = cell(1,n^3);
lbl = zeros(1,n^3);
r   = zeros(3,n^3);
for i = 1:n
  for j = 1:n
    for k = 1:n
      rL = rL0 + [x(i);y(j);z(k)];
      rho{p} = Ladar(h,rL,xY,angleSamp,nSamp);
      r(:,p) = rL;
      p      = p + 1;
      plot3(rL(1),rL(2),rL(3),'o','linewidth',0.1,'MarkerFaceColor',[1 0 0]);
    end
  end
end

s = size(rho{1});
save('LadarMeasurements','rho', 'r', 's');
