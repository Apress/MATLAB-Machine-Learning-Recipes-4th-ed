%% Sparse matrix
% Compares a sparse matrix with a regular matrix

n = 100;
a = sprand(n,n,0.1);
b = sprand(n,1,0.1);
disp('Sparse matrix: linear equations')
tic
c = a\b;
toc

disp('Sparse matrix: eigenvalue')
tic
eigs(a);
toc

a = full(a);
b = full(b);
disp('Regular matrix: linear equations')
tic
c = a\b;
toc

disp('Regular matrix: eigenvalue')
tic
eig(a);
toc


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
