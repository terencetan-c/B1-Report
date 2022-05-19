function [ymin, ymax] = interval_bound_propagation(W,b,xmin,xmax)
    
    % Initialise the upper and lower bound from layer l-1
    z_hat_max_previous = xmax;
    z_hat_min_previous = xmin;
    
    % Loop through first four layers
    for i = 1:1:4
        
        W_plus = max(W{i},0);   % W_plus for layer l
        W_minus = min(W{i},0);  % W_minus for layer l
        
        % Calculate upper and lower bound for layer l
        z_hat_max = W_plus*z_hat_max_previous + W_minus*z_hat_min_previous + b{1,i};
        z_hat_min = W_plus*z_hat_min_previous + W_minus*z_hat_max_previous + b{1,i};
        
        % Apply ReLU function
        z_hat_max = max(0,z_hat_max);
        z_hat_min = max(0, z_hat_min);
        
        % Reassignment of variables for next loop
        z_hat_max_previous = z_hat_max;
        z_hat_min_previous = z_hat_min;
        
    end
 
    W_plus = max(W{5},0);
    W_minus = min(W{5},0);
        
    ymax = W_plus*z_hat_max_previous + W_minus*z_hat_min_previous + b{5};
    ymin = W_plus*z_hat_min_previous + W_minus*z_hat_max_previous + b{5};
    
end