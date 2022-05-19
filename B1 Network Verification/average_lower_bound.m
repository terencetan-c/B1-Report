% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Define maximum value of k
k_max = 350;

% Initialise zero vectors
lower_bound = zeros(1,k_max);   % Lower bound for each value of k
average_lowerbound = zeros(1,500);  % Average lower bound for each property
false_flag = zeros(1,500);  % Flags any counter-examples

% Loop through each file
for fidx=1:numel(filelist)
    
    % Load the file
    X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
    % Loop through k from 1 to k_max and perform the computations
    for k = 1:1:k_max
        input = generate_inputs(X.xmin,X.xmax, k);  % Generate the inputs
        input = transpose(input);   % Transpose input so that dimensions match
        
        % Compute neural network output and find the largest output (lower
        % bound)
        lower_bound(k) = max(compute_nn_outputs(X.W, X.b, input));
        
        % Checks if there are any counter-exmaples
        if lower_bound(k) > 0
            false_flag(fidx) = 1;
        end
    end
    average_lowerbound(fidx) = sum(lower_bound)/k_max;  % Sum up and average for each property
end

% Plot average lower bound for each property
plot(1:500, average_lowerbound);
title('Plot of average lower bound (averaged over k) against property');
xlabel('Property');
ylabel('Average lower bound');
grid on

