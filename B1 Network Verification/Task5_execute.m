% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Initialise vectors

bounds = zeros(500,2);


%numel(filelist)
% Loop through each file
for fidx=1:numel(filelist)
    
    % Load the file
    file=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
    W = file.W;
    b = file.b;
    xmin = file.xmin;
    xmax = file.xmax;
    [bounds(fidx,1), bounds(fidx,2)] = linear_programming_bound2(W,b,xmin,xmax);
    
end


average_bounds = mean(bounds);
num_of_false = sum(bounds(:,1) > 0);
num_of_true = sum(bounds(:,2) <= 0);
    