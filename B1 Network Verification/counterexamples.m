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


num_of_false = sum(false_flag); % Number of properties with counter-examples found
num_of_true = 500-num_of_false; % Number of properties with no counter-examples found

% Plot a bar graph with labels
bar_x = categorical({'Found a counter-example','Did not find a counter-example'});
bar_x = reordercats(bar_x,{'Found a counter-example','Did not find a counter-example'});
bar_y = [num_of_false, num_of_true];
b = bar(bar_x,bar_y);
ylim([0,450]);
ylabel('Number of properties')
title('Number of properties for which a counter-example was or was not found');

% Add the actual numbers onto the bar graph
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')