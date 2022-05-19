% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

% Initialise vectors
k_max = 10;
lower_bounds = zeros(k_max,1);
total_lowerbounds = zeros(k_max,1);
individual_time = zeros(k_max,1);   % Time taken for each value of k for each individual property
time = zeros(k_max,1);   % Time taken for each value of k for all properties
num_of_falseproperties = zeros(k_max,1);

%numel(filelist)
% Loop through each file
for fidx=1:numel(filelist)
    
    false_flag = zeros(k_max,1);  % Flags any False properties

    % Load the file
    file=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
    
    W = file.W;
    b = file.b;
    xmin = file.xmin;
    xmax = file.xmax;
    
    for k = 1:k_max
        X = generate_inputs(xmin,xmax,k);
        tic
        refined_X = projected_gradient_ascent(W,b,transpose(X),transpose(xmin),transpose(xmax));
        y = compute_nn_outputs(W, b, refined_X);    % Compute neural network output
        individual_time(k) = toc;   % End timer and place time into the initialised vector
        
        largest_lowerbound = max(y);
        
        if largest_lowerbound > 0
            false_flag(k) = 1;
        end
            
        lower_bounds(k) = largest_lowerbound;
        
    end
    
    time = individual_time + time;  % Add up all the individual timings for each property
    total_lowerbounds = total_lowerbounds + lower_bounds;
    num_of_falseproperties = num_of_falseproperties + false_flag;
    
end

% Divide by 500 to get average time/lower bounds for each value of k over all 500
% properties
average_time = time./500;
average_lowerbounds = total_lowerbounds./500;

% Plot average time against values of k

figure(1);
plot(1:k_max,average_time);
title('Plot of average amount of time (over 500 properties) against k');
xlabel('k');
ylabel('Average amount of time (over all 500 properties)');
grid on

figure(2);
plot(1:k_max,average_lowerbounds);
title('Plot of average lower bound (over 500 properties) against k');
xlabel('k');
ylabel('Average lowerbound (over all 500 properties)');
grid on

figure(3);
plot(1:k_max, num_of_falseproperties);
title('Plot of number of properties for which a counter-example is found against k');
xlabel('k');
ylabel('Number of properties for which a counter-example is found (proven false)');
yline(172,'r');
legend('number of counter-examples found','actual number of false properties');
grid on
      
        
