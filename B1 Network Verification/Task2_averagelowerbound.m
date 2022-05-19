% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Initialise zero vectors
false_flag = zeros(1,500);  % Flags any False properties
true_flag = zeros(1,500);  % Flags any True properties
total_bounds = zeros(1,2);

% Loop through each file
for fidx=1:numel(filelist)
    
    % Load the file
    X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
        
    % Compute neural network output and find the largest output (lower
    % bound)
    
    xmin = transpose(X.xmin);
    xmax = transpose(X.xmax);
    [ymin,ymax] = interval_bound_propagation(X.W,X.b,xmin,xmax);
    
    
    % Checks if there are any counter-exmaples
    if ymin > 0
        false_flag(1,fidx) = 1;
    elseif ymax <= 0
        true_flag(1,fidx) = 1;
    end
    total_bounds = total_bounds + [ymin,ymax];  % Add up the bounds
    
 
end

average_bound = total_bounds./500;  % [ymin_average, ymax_average]
num_of_false = sum(false_flag);
num_of_true = sum(true_flag);
