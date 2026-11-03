%% Statistics
% Generate 10 bathtub curves with random infant mortality and old life
% slopes. Both are absolute normal distributions
alpha = 1/10000;
t      = linspace(0,300,120);
n      = 10;
betaS  = [0.8*abs(rand(n,1)) 1+abs(randn(n,1))];
for k = 1:10
  beta   = [betaS(k,1)*ones(1,20) ones(1,70) betaS(k,2)*ones(1,30)];
  y(k,:) = BathtubCurve(beta,t,alpha);
end
Plot2D(t,y,'Time','y','Noisy Bathtub Curve')
betaS