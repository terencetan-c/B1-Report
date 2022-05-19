% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));
X=load(fullfile(filelist(499).folder, filelist(499).name));

xmin = transpose(X.xmin);
xmax = transpose(X.xmax);
W = X.W;
b = X.b;
P_max = 10;
X_original = [xmin,xmax];   % Original domain
k_max = 20;
P = cell(1,P_max+1);
P{1} = X_original;  % Initialise the first partition, which is just the entire input domain
%n = length(P); % Size of partition (should be size 1 AKA no partitions yet)
flag = 'unknown';   % Initialise flag
bounds = zeros(P_max+1,2);    % Initialise zero vector of bounds
time = zeros(1,P_max);  % Initialise time vector

X_j = P{1}; % Extract the jth subdomain from Partition set
[~,ymax] = interval_bound_propagation(W,b,X_j(:,1),X_j(:,2));    % Compute upper bound

% Compute lower bound using method from Task 1
input = generate_inputs(transpose(xmin),transpose(xmax), k_max);  % Generate the inputs
input = transpose(input);
ymin = max(compute_nn_outputs(W,b,input));

% Insert bounds for entire domain into Bounds set
bounds(1,1)=ymin;
bounds(1,2)=ymax;

% Partition original domain into P_max subdomains or until a flag is
% raised
for i = 1:P_max

    tic%Start timer

    [M,J] = max(bounds(:,2));   % J is the index of X in P that has the highest upper bound

    % Check if upper bound is negative and exit loop if so
    if M<=0
        flag = 1;
        time(1,i) = toc;
        break
    end

    X_prime = P{J}; % Subdomain with the highest upper bound

    s = (X_prime(:,2)-X_prime(:,1))./(X_original(:,2)-X_original(:,1)); % Relative length of kth dimension of the subdomain to original domain

    [~,k] = max(abs(s)); % K is the largest relative length, k is the index of K

    % Split X_prime into two subdomains
    X1_prime = X_prime;
    X2_prime = X_prime;

    X1_prime(k,2) = X_prime(k,1) + 0.5*(X_prime(k,2)-X_prime(k,1));
    X2_prime(k,1) = X1_prime(k,2);

    % Compute upper bounds for new subdomains
    [~,new_upperbound1] = interval_bound_propagation(W,b,X1_prime(:,1),X1_prime(:,2));
    [~,new_upperbound2] = interval_bound_propagation(W,b,X2_prime(:,1),X2_prime(:,2));

    % Compute lower bounds for new subdomains
    input1 = generate_inputs(transpose(X1_prime(:,1)),transpose(X1_prime(:,2)), k_max);  % Generate the inputs
    input1 = transpose(input1);
    new_lowerbound1 =  max(compute_nn_outputs(W,b,input1)); % Lower bound for first new subdomain

    input2 = generate_inputs(transpose(X2_prime(:,1)),transpose(X2_prime(:,2)), k_max);  % Generate the inputs
    input2 = transpose(input2);
    new_lowerbound2 = max(compute_nn_outputs(W,b,input2));  % Lower bound for second new subdomain

    % Check lower bounds and terminate loop if at least one is positive
    if (new_lowerbound1 > 0) || (new_lowerbound2 > 0) == 1
        flag = 0;
        time(i) = toc;
        break
    end

    % Increase partition size by one
    %P(J) = [];  % Remove X_prime from the Partition set
    %bounds(J,:)=[]; % Remove the bounds of X_prime 

    P{J} = X1_prime;
    P{i+1} = X2_prime;

    %P{end+1} = X1_prime;    % Insert first new subdomain into Partition set
    %P{end+1} = X2_prime;    % Insert second new subdomain into Partition set

    %bounds(end+1,:) = [new_lowerbound1,new_upperbound1];    % Insert bounds for X1_prime into Bounds set
    %bounds(end+1,:) = [new_lowerbound2,new_upperbound2];    % Insert bounds for X2_prime into Bounds set

    bounds(J,:) = [new_lowerbound1,new_upperbound1];
    bounds(i+1,:) = [new_lowerbound2,new_upperbound2];

    % toc gives the time taken for the ith iteration and not time taken for i
    % iterations. If i iterations take T(i) time, then time taken for
    % i+k iterations is T(i) + t(i+1) + t(i+2) + .... + t(t+k) where
    % t(i) is the time taken for the ith iteration. Basically, we have
    % to sum up all the time taken for each individual iterations from the first iteration up to
    % the (i+k)th iteration in order to get the time taken to run Bound and Branch for
    % P_max = i+k total iterations
    time(1,i:end) = time(1,i:end) + toc;    % time(i) is time taken to run Bound and Branch for one particular property for P_max = i iterations


end   




