M = 15;     dx = 0.125;     dt = 0.05;      X = 0:dx:pi;    T = 0:dt:2;    
Xx = repmat(X,[length(T) 1]);    Tt = repmat(T',[1 length(X)]);
% Heat equation 
temp = 2*(1:M)-1;   coeff = 8 ./ (pi * (temp.^3));
he = @(x,t) reshape( (sin(double(x(:))*temp) .* exp(-double(t(:))*(temp.^2))) * coeff(:), size(x) );
u = he(Xx,Tt);
% Initial condition u(x,0)
ic = @(x) reshape( sin(double(x(:))*temp) * coeff(:), size(x) );
% Noisy measurements (data) 
noise_level = 0.60 * std(u(:));
u_noise = u + noise_level * randn(size(u));
% Split test train validation
xAll = Xx(:); tAll = Tt(:);     y = u(:);       y_noise = u_noise(:);
train_val_test = train_val_test_split(xAll,tAll,y,y_noise);
% MLP and PINN with same architecture 
layers = [  featureInputLayer(2, "Normalization","none")
            fullyConnectedLayer(128)
            tanhLayer
            fullyConnectedLayer(128)
            tanhLayer
            fullyConnectedLayer(128)
            tanhLayer
            fullyConnectedLayer(1) ];
lgraph = layerGraph(layers);
mlp  = dlnetwork(lgraph); pinn = dlnetwork(lgraph);
% Learning rate, batch size, training steps
LR = 1e-3;      BATCH = 4096;    STEPS = 1500;    PRINT_EVERY = 50;
% PINN collocation sizes & loss weights
Nc = 4096; Nb = 2048; Ni = 2048;
wPDE = 1.0; wBC = 1.0; wIC = 1.0; wData = 0.01;
xMin = 0; xMax = pi; tMin = 0; tMax = 2;
% Train MLP and PINN
[mlp, mlpValLoss, mlpLog] = train_mlp(mlp, train_val_test, LR,BATCH,STEPS, PRINT_EVERY);
[pinn, pinnValLoss, pinnLog] = train_pinn(pinn, train_val_test, ic, ...
    LR, BATCH, STEPS, Nc, Nb, Ni, wPDE, wBC, wIC, wData, xMin, xMax, tMin, tMax, PRINT_EVERY);



function S = train_val_test_split(xAll,tAll,y,y_noise)
perm = randperm(numel(xAll));
n = numel(xAll);
nTr  = floor(0.8*n);
nVal = floor(0.1*n);

idxTr  = perm(1:nTr);
idxVal = perm(nTr+1:nTr+nVal);
idxTest= perm(nTr+nVal+1:end);

S.xTr = xAll(idxTr);   S.tTr = tAll(idxTr);   S.yTrNoisy = y_noise(idxTr);
S.xVal = xAll(idxVal); S.tVal = tAll(idxVal); S.yValClean = y(idxVal);
S.xTest = xAll(idxTest); S.tTest = tAll(idxTest); S.yTestClean = y(idxTest);

S.dlInVal = [dlarray(single(S.xVal.'),'CB');  dlarray(single(S.tVal.'),'CB')];
S.dlYvalClean = dlarray(single(S.yValClean.'),'CB');

S.dlInTest = [dlarray(single(S.xTest.'),'CB'); dlarray(single(S.tTest.'),'CB')];
S.dlYtestClean = dlarray(single(S.yTestClean.'),'CB');
end


function [net,valLoss,logs] = train_mlp(net,S,LR,BATCH,STEPS,PRINT_EVERY)
ta=[]; tv=[]; valLoss=zeros(STEPS,1,'single'); logs=cell(STEPS,1);
for step=1:STEPS
    idx = randi(numel(S.xTr),[BATCH,1]);
    dlIn = [dlarray(single(S.xTr(idx)).','CB'); dlarray(single(S.tTr(idx)).','CB')];
    dlY  = dlarray(single(S.yTrNoisy(idx)).','CB');
    % data loss only
    [lossTr,grads] = dlfeval(@mlpLoss, net, dlIn, dlY);
    [net,ta,tv] = adamupdate(net,grads,ta,tv,step,LR,0.9,0.999);
    v = mean((forward(net,S.dlInVal)-S.dlYvalClean).^2,'all');
    valLoss(step) = extractdata(v);

    msg = sprintf('[MLP %4d/%4d] train(noisy)=%.6f | val(clean)=%.6f\n', ...
        step,STEPS,extractdata(lossTr),valLoss(step));
    logs{step}=msg;

    if mod(step,PRINT_EVERY)==0 || step==1 || step==STEPS
        fprintf('%s',msg); drawnow limitrate;
    end
end
end

function [loss,grads] = mlpLoss(net,dlIn,dlY)
yhat = forward(net,dlIn);
loss = mean((yhat-dlY).^2,'all');
grads = dlgradient(loss, net.Learnables);
end


function [net,valLoss,logs] = train_pinn(net,S,ic,LR,BATCH,STEPS, ...
    Nc,Nb,Ni,wPDE,wBC,wIC,wData,xMin,xMax,tMin,tMax,PRINT_EVERY)

ta=[]; tv=[]; valLoss=zeros(STEPS,1,'single'); logs=cell(STEPS,1);

for step=1:STEPS
    % Interior points (used to check the PDE: u_t = u_xx)
    dlXc = dlarray(xMin+(xMax-xMin)*rand(1,Nc,'single'),'CB');
    dlTc = dlarray(tMin+(tMax-tMin)*rand(1,Nc,'single'),'CB');
 
    % Boundaies
    dlTb  = dlarray(tMin+(tMax-tMin)*rand(1,Nb,'single'),'CB');
    dlXb0 = dlarray(zeros(1,Nb,'single')+xMin,'CB'); %left
    dlXb1 = dlarray(zeros(1,Nb,'single')+xMax,'CB'); % right
    
    % initial time t = 0
    dlXi = dlarray(xMin+(xMax-xMin)*rand(1,Ni,'single'),'CB');
    dlT0 = dlarray(zeros(1,Ni,'single')+tMin,'CB');
    % initial condition values u(x,0)
    dlU0 = dlarray(single(ic(extractdata(dlXi))),'CB');
   
    % Randomly choose noisy training data points
    idx = randi(numel(S.xTr),[BATCH,1]);
    dlXd = dlarray(single(S.xTr(idx)).','CB');    %x
    dlTd = dlarray(single(S.tTr(idx)).','CB');    %t
    dlYd = dlarray(single(S.yTrNoisy(idx)).','CB'); % u

    [tot,pde,bc,icL,data,grads] = dlfeval(@pinnLoss, net, ...
        dlXc,dlTc, dlXb0,dlXb1,dlTb, dlXi,dlT0,dlU0, dlXd,dlTd,dlYd, ...
        wPDE,wBC,wIC,wData);

    [net,ta,tv] = adamupdate(net,grads,ta,tv,step,LR,0.9,0.999);

    v = mean((forward(net,S.dlInVal)-S.dlYvalClean).^2,'all');
    valLoss(step) = extractdata(v);

    msg = sprintf('[PINN %4d/%4d] total=%.6f (pde=%.6f, bc=%.6f, ic=%.6f, data=%.6f) | val(clean)=%.6f\n', ...
        step,STEPS,extractdata(tot),extractdata(pde),extractdata(bc),extractdata(icL),extractdata(data),valLoss(step));
    logs{step}=msg;

    if mod(step,PRINT_EVERY)==0 || step==1 || step==STEPS
        fprintf('%s',msg); drawnow limitrate;
    end
end
end

function [total,pde,bc,icL,data,gr]=pinnLoss(net, ...
    dlXc,dlTc, dlXb0,dlXb1,dlTb, dlXi,dlT0,dlU0, dlXd,dlTd,dlYd, ...
    wPDE,wBC,wIC,wData)
u_c = forward(net,[dlXc;dlTc]);
[ux,ut] = dlgradient(sum(u_c,'all'), dlXc, dlTc,'EnableHigherDerivatives',true);
uxx = dlgradient(sum(ux,'all'), dlXc,'EnableHigherDerivatives',true);
pde = mean((ut - uxx).^2,'all');
bc = mean(forward(net,[dlXb0;dlTb]).^2,'all') + ...
     mean(forward(net,[dlXb1;dlTb]).^2,'all');
icL  = mean((forward(net,[dlXi;dlT0]) - dlU0).^2,'all');
data = mean((forward(net,[dlXd;dlTd]) - dlYd).^2,'all');
total = wPDE*pde + wBC*bc + wIC*icL + wData*data;
gr = dlgradient(total, net.Learnables);
end