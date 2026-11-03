model = createpde();
geometryFromEdges(model,@circleg);
applyBoundaryCondition(model,"dirichlet", ...
    "Edge",1:model.Geometry.NumEdges,"u",0);

pdeCoeffs.c = .5;     % initial guess
pdeCoeffs.m = 0;
pdeCoeffs.d = 0;
pdeCoeffs.a = 0;
pdeCoeffs.f = 1;
pdeCoeffs = structfun(@dlarray,pdeCoeffs,'UniformOutput',false);

layers = [
    featureInputLayer(2)
    fullyConnectedLayer(50) tanhLayer
    fullyConnectedLayer(50) tanhLayer
    fullyConnectedLayer(1)
];
pinn = dlnetwork(layers);
classicNN = dlnetwork(layers);

U = forward(pinn,XY);
gradU = dlgradient(sum(U,'all'),XY,'EnableHigherDerivatives',true);
Laplacian = dlgradient(sum(pdeCoeffs.c.*gradU,'all'),XY, ...
    'EnableHigherDerivatives',true);
res = -pdeCoeffs.f - Laplacian + pdeCoeffs.a.*U;
lossPDE = mean(res.^2,'all');
lossData = l2loss(U,getSolutionData(XY));
loss = lossPDE + lossData;