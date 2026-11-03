X = single([0 0 1 1; 0 1 0 1]); T = [0; 1; 1; 0];  % Inputs columns X \& targets
layers = [
    featureInputLayer(2, Normalization="none")
    fullyConnectedLayer(4)
    tanhLayer
    fullyConnectedLayer(1)
    sigmoidLayer
    regressionLayer % Computes loss during training
];
net = trainNetwork(X', single(T), layers, trainingOptions("adam", MaxEpochs=2000, Verbose=false)); % Train network

% Convert trained weights/biases to fixed-point
W1 = fi(net.Layers(2).Weights, 1, 16, 12);
b1 = fi(net.Layers(2).Bias,    1, 16, 12);
W2 = fi(net.Layers(4).Weights, 1, 16, 12);
b2 = fi(net.Layers(4).Bias,    1, 16, 12);
disp('--- LUT HDL NN ---')
% Test all 4 XOR cases using fixed-point inference
for i = 1:4
    x1 = fi(X(1,i),1,16,12);
    x2 = fi(X(2,i),1,16,12);
    % Run HDL-style NN with LUT activations
    y  = xor_nn(x1,x2,W1,b1,W2,b2);
    % Convert result to double and round to 0/1
    yd = double(y);
    yp = round(yd);
    % Print prediction and expected value
    fprintf('[%d %d] -> raw: %.4f -> pred: %d (exp: %d)\n', ...
        X(1,i), X(2,i), yd, yp, T(i));
end

% Testing HDL-friendly NN forward pass
function y = xor_nn(x1,x2,W1,b1,W2,b2)
    x = [x1;x2]; % Inputs
    h = fi(zeros(4,1),1,16,12);
    % Hidden layer: weighted sum + tanh LUT
    for i = 1:4
        z = b1(i);
        for j = 1:2
            z = z + W1(i,j)*x(j);
        end
        h(i) = tanh_lut(z);
    end
    % Output layer: weighted sum + sigmoid LUT
    z2 = b2;
    for k = 1:4
        z2 = z2 + W2(1,k)*h(k);
    end
    y = sigmoid_lut(z2);
end

%% tanh LUT approximation
function y = tanh_lut(x)
    xd = double(x);

    if xd < -3
        yd = -1;
    elseif xd < -2
        yd = -0.96;
    elseif xd < -1
        yd = -0.76;
    elseif xd < -0.5
        yd = -0.46;
    elseif xd < 0.5
        yd = xd;
    elseif xd < 1
        yd = 0.46;
    elseif xd < 2
        yd = 0.76;
    elseif xd < 3
        yd = 0.96;
    else
        yd = 1;
    end

    % Fixed-point result
    y = fi(yd,1,16,12);
end

%% sigmoid LUT approximation
function y = sigmoid_lut(x)
    xd = double(x);
    
    if xd < -3
        yd = 0;
    elseif xd < -2
        yd = 0.05;
    elseif xd < -1
        yd = 0.12;
    elseif xd < -0.5
        yd = 0.27;
    elseif xd < 0.5
        yd = 0.5 + xd/4;
    elseif xd < 1
        yd = 0.73;
    elseif xd < 2
        yd = 0.88;
    elseif xd < 3
        yd = 0.95;
    else
        yd = 1;
    end

    % Return fixed-point result
    y = fi(yd,0,16,12);
end