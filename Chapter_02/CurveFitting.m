%% Fit a cubic to a 2nd order polynomial

Mdl = incrementalClassificationLinear('EstimationPeriod',5000,'Solver','sgd')
x = linspace(0,10);
y = x.^3 + x.^2 + 3*x + 1 + 2*randn(1,length(x));
f = fit(Mdl,x,y,'poly2');

Plot2D(x,[y;y2],'y','Polynomial fit')
legend('y','y fit')