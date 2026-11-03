function LED = xor_nn_hdl(x1, x2)
% Inputs: x1, x2
% Output: LED = 0 or 1
persistent W1 b1 W2 b2 % Keep weights/biases between calls
T = numerictype(1,16,12); % Fixed-point type
% Load trained weights once
if isempty(W1)
    W1 = fi([ ...
       -2.1619  -1.7122;
       -1.8801   0.9836;
       -1.7986   2.4858;
       -1.6233  -1.7056], T);
    b1 = fi([ ...
        0.1619;
       -0.3901;
        0.7327;
       -0.1228], T);
    W2 = fi([ ...
       -1.9817   2.9180  -2.2639  -1.0938], T);
    b2 = fi(-0.0994, T);
end
x = fi([x1; x2], T);
% Store hidden layer outputs
h = fi(zeros(4,1), T);
for i = 1:4
    z = fi(b1(i), T);
    for j = 1:2
        z = fi(z + fi(W1(i,j) * x(j), T), T);
    end
    % Apply tanh approximation
    h(i) = tanh_lut(z);
end
z2 = fi(b2, T);
for k = 1:4
    z2 = fi(z2 + fi(W2(1,k) * h(k), T), T);
end
% Apply sigmoid approximation
y = sigmoid_lut(z2);

% Final decision: threshold at 0.5
if y > fi(0.5, 0,16,12)
    LED = fi(1, 0,1,0);   % XOR = 1
else
    LED = fi(0, 0,1,0);   % XOR = 0
end
end