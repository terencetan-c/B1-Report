% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Define maximum value of k
k_max = 350;

% Initialise zero vectors
individual_time = zeros(k_max,1);   % Time taken for each value of k for each individual property
time = zeros(k_max,1);  % Time taken for each value of k for all 500 properties
    
% Loop through each file
for fidx=1:numel(filelist)
    
    % Load the file
    X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
    % Loop through k from 1 to k_max and perform the computations
    for k = 1:1:k_max
        input = generate_inputs(X.xmin,X.xmax, k);  % Generate the inputs
        input = transpose(input);   % Transpose input so that dimensions match
        
        % Start timer
        tic
        compute_nn_outputs(X.W, X.b, input);    % Compute neural network output
        individual_time(k) = toc;   % End timer and place time into the initialised vector
    end
    
    % Add up all the individual timings for each property
    time = individual_time + time;
    
end

% Divide by 500 to get average time for each value of k over all 500
% properties
average_time = time./500;

% Plot average time against values of k
plot(1:k_max,average_time);

