% Specify file path to get the dataset
folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));

%X=load(fullfile(filelist(489).folder, filelist(489).name));



%[flag,M,i,new_lowerbound1,new_lowerbound2,X_j,s,X1_prime,X2_prime,X_prime,k,bounds,P] = branch_and_bound(W,b,xmin,xmax);

%[zmin,zmax]=interval_bound_propagation(W,b,X1_prime(:,1),X1_prime(:,2));

true_flag = zeros(1,500);
false_flag = zeros(1,500);
P_max = 1000000;
%P_max = 20;
total_time = zeros(1,P_max);
total_proven = zeros(1,P_max);



for fidx=1:numel(filelist)

    % Load the file
    X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));

    xmin = transpose(X.xmin);
    xmax = transpose(X.xmax);
    W = X.W;
    b = X.b;


    [flag,time,I] = task5_branch_and_bound(W,b,xmin,xmax,P_max);

    if flag == 1
        true_flag(fidx) = 1;
        %total_proven(1,I:end) = total_proven(1,I:end) + 1;
        total_proven(1,I) = total_proven(1,I) + 1;
    elseif flag == 0
        false_flag(fidx) = 1;
        %total_proven(1,I:end) = total_proven(1,I:end) + 1;
        total_proven(1,I) = total_proven(1,I) + 1;

    end
    
    total_time = total_time + time;
end

total_proven = cumsum(total_proven);
num_of_true = sum(true_flag);
num_of_false = sum(false_flag);
%total_proven(P_max) = num_of_true + num_of_false;

%for j = 2:P_max
%    total_proven(j) = total_proven(j) + total_proven(j-1);
    %total_time(j) = total_time(j) + total_time(j-1);
%end

plot([0,total_time],[0,total_proven]);
title('Plot of number of properties that have been verified as either true or false against time taken');
xlabel('Time taken by Branch and Bound procedure (seconds)');
ylabel('Number of properties that have been verified');
ylim([0 550]);
dim = [0.55 0.1 1 0.2];
str = {'Number of verified true properties:' num_of_true, 'Number of verified false properties:' num_of_false};
annotation('textbox',dim,'String',str,'FitBoxToText','on');

grid on