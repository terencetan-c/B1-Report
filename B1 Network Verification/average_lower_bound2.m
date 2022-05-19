% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Define maximum value of k
k_max = 350;

% Initialise zero vectors
lower_bound = zeros(1,k_max);   % Lower bound for each value of k
total_lowerbound = zeros(1,k_max);
total_flag = zeros(1,k_max);

% Loop through each file
for fidx=1:numel(filelist)
    
    % Load the file
    X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
    false_flag = zeros(1,k_max);  % Flags any counter-examples for each k
    
    % Loop through k from 1 to k_max and perform the computations
    for k = 1:1:k_max
        input = generate_inputs(X.xmin,X.xmax, k);  % Generate the inputs
        input = transpose(input);   % Transpose input so that dimensions match
        
        % Compute neural network output and find the largest output (lower
        % bound)
        lower_bound(k) = max(compute_nn_outputs(X.W, X.b, input));
        
        % Checks if there are any counter-exmaples
        if lower_bound(k) > 0
            false_flag(k) = 1;
        end
    end
    total_lowerbound = total_lowerbound + lower_bound;  % Sum up the lower bound for all properties for each value of k
    total_flag = total_flag + false_flag;
end

average_lowerbound = total_lowerbound./500;
% Plot average lower bound for each property
figure(1);
plot(1:k_max, average_lowerbound);
title('Plot of average lower bound (over all 500 properties) against k');
xlabel('value of k');
ylabel('average lower bound');
grid on

figure(2)
plot(1:k_max, total_flag);
title('Plot of number of counter-examples found against k');
xlabel('value of k');
ylabel('Number of properties for which a counter-example was found');



grid on

