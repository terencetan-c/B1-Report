% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

%X=load(fullfile(filelist(489).folder, filelist(489).name));



%[flag,M,i,new_lowerbound1,new_lowerbound2,X_j,s,X1_prime,X2_prime,X_prime,k,bounds,P] = branch_and_bound(W,b,xmin,xmax);

%[zmin,zmax]=interval_bound_propagation(W,b,X1_prime(:,1),X1_prime(:,2));

true_flag = zeros(1,500);
false_flag = zeros(1,500);
P_max = 100;
time = zeros(1,P_max);
total = zeros(1,P_max);


for P = 1:P_max
    tic
    for fidx=1:numel(filelist)

        % Load the file
        X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));

        xmin = transpose(X.xmin);
        xmax = transpose(X.xmax);
        W = X.W;
        b = X.b;

        
        flag = branch_and_bound(W,b,xmin,xmax,P);

        if flag == 1
            true_flag(fidx) = 1;
        elseif flag == 0
            false_flag(fidx) = 1;

        end
    end
    time(P) = toc;

    num_of_true = sum(true_flag);
    num_of_false = sum(false_flag);
    total(P) = num_of_true + num_of_false;
end
plot(time,total);