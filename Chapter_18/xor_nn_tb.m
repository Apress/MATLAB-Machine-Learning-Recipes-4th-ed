% Testbench for the HDL-style XOR network
% All 4 XOR input cases
X = [0 0 1 1;
     0 1 0 1];
% Expected XOR outputs
T = [0 1 1 0];
% Test each input pair
for i = 1:4
    % Convert inputs to fixed-point
    x1 = fi(X(1,i),1,16,12);
    x2 = fi(X(2,i),1,16,12);
    % Run the HDL-style network
    LED = xor_nn_hdl(x1, x2);
    % Print output and expected result
    fprintf('[%d %d] -> LED: %d (exp: %d)\n', ...
        X(1,i), X(2,i), LED, T(i));
end