% Compute neural network output

function y = compute_nn_outputs(W,b,X)

    % Loop through the first four layers (not including Layer 0)
    for i = 1:1:4
        % Multiply each input by weight and add bias
        % We can add the two terms even though the dimensions do not match
        % because of broadcasting
        X = W{i}*X + b{i};
        
        % Rectified linear unit
        X = max(X,0);
    end
    
    % Perform the last layer outside of the loop as the output y does not
    % need ReLU
    y = W{5}*X + b{5};  % 1 x k vector
    y = transpose(y);   % We want a k x 1 output
end