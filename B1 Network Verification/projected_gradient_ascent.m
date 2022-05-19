function refined_X = projected_gradient_ascent(W,b,X,xmin,xmax)

    stepsize = 0.0005;  % Define stepsize
    %iteration = 1000;   % Set the number of iterations
    ReLU = {0,0,0,0};   % Initialise zero array
    k = length(X(1,:)); % Find how many different sets of inputs we have
    cutoff = 0.00001;   % Cutoff below which we can terminate the gradient ascent
    difference = cutoff;    % Initalise difference between X(iter) and X(iter-1)
    %iter = 1;   % Initalise while loop count
    %for iter = 1:iteration
    while difference >= cutoff
        x = X; % Preserve the value of X so that we can increment it later
        
        % Loop through the first four layers
        for i = 1:1:4
            
            derivative_ReLU = [];   % Initalise an empty matrix for derivatives of ReLU function
            
            % Multiply each input by weight and add bias
            % We can add the two terms even though the dimensions do not match
            % because of broadcasting
            x = W{i}*x + b{i};

            % Rectified linear unit
            x = max(x,0);
            
            % We need to find the derivative of ReLU functions for each
            % layer. For a scalar, derivative of ReLU(x) is 1 for x>0 and 0
            % otherwise. For vectors, the derivative is a diagonal matrix,
            % where the jth diagonal entry is the derivative of ReLU evaluated at the jth scalar element of the vector
            % In this case we need to create a diagonal matrix for each of
            % the k columns.
            
            individual_ReLU_derivative = x>0;   % this is a (number of rows of W{i}) by k matrix
            
            % Create a 3d array with a diagonal matrix formed from the jth column
            % of the above matrix in its jth page (the third dimension)
            for j = 1:k
                derivative_ReLU(:,:,j) = diag(individual_ReLU_derivative(:,j)); %dimension: (number of rows of W{i}) by (number of rows of W{i}) by k
            end
            
            ReLU{i} = derivative_ReLU;  % Insert our 3d matrix into our initialised cell array
            
                
        end

      
        % Apply chain rule on the entire neural network to get its
        % derivative. Use pagemtimes to multiply a 2d matrix with each page of a 3d
        % matrix (of course, the rows and columns must still match). Thus,
        % a derivative is computed for each of the k pages
        dfdx = pagemtimes(W{5},pagemtimes(ReLU{4},pagemtimes(W{4},pagemtimes(ReLU{3},pagemtimes(W{3},pagemtimes(ReLU{2},pagemtimes(W{2},pagemtimes(ReLU{1},W{1}))))))));
        
        % dfdx above is a 1 x 6 x k matrix so use permute function to
        % transform it into a 6 x 1 matrix (we swap the row and page so we get
        % k rows and 1 page which essentially 'erases' the third dimension)
        dfdx = permute(dfdx,[3 2 1]);
        dfdx = transpose(dfdx); % We can now transpose our 2d dfdx
        
        X_previous = X; % Store the current value of X before incrementing it to check cutoff
        
        % Increment x in the direction that increases the output the most
        X = X + (stepsize*dfdx);
        
        % Clip the values in X so that X is within the given domain
        X = max(X,xmin);
        X = min(X,xmax);
        
        difference = abs(X - X_previous);   % Calculate difference to compare with cutoff
        
        %iter = iter + 1;    % Increment loop count
    end
    
    % After iterations, assign output
    refined_X = X;

        