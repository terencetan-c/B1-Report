function [ymin,ymax] = linear_programming_bound2(W,b,xmin,xmax)
    
    size_of_variables = 6+(40+40+38+19)*2;
    lowerbounds = xmin;
    upperbounds = xmax;
    lowerbound_hat_cell = {0,0,0,0};
    upperbound_hat_cell = {0,0,0,0};
    lowerbound_cell = {0,0,0,0};
    upperbound_cell = {0,0,0,0};
    % Initialise the upper and lower bound from layer l-1
    z_hat_max_previous = transpose(xmax);
    z_hat_min_previous = transpose(xmin);

    % Loop through first four layers
    for i = 1:1:4


        W_plus = max(W{i},0);   % W_plus for layer l
        W_minus = min(W{i},0);  % W_minus for layer l

        % Calculate upper and lower bound for layer l
        z_hat_max = W_plus*z_hat_max_previous + W_minus*z_hat_min_previous + b{1,i};
        z_hat_min = W_plus*z_hat_min_previous + W_minus*z_hat_max_previous + b{1,i};

        %lowerbounds = cat(2,lowerbounds,z_hat_min);
        %upperbounds = cat(2,upperbounds,z_hat_min);

        lowerbound_hat_cell{i} = z_hat_min;
        upperbound_hat_cell{i} = z_hat_max;

        % Apply ReLU function
        z_hat_max = max(0,z_hat_max);
        z_hat_min = max(0, z_hat_min);

        %lowerbounds = cat(2,lowerbounds,z_hat_min);
        %upperbounds = cat(2,upperbounds,z_hat_min);

        lowerbound_cell{i} = z_hat_min;
        upperbound_cell{i} = z_hat_max;
        % Reassignment of variables for next loop
        z_hat_max_previous = z_hat_max;
        z_hat_min_previous = z_hat_min;

    end

    %xmax = transpose(xmax);
    %xmin = transpose(xmin);

    options = optimoptions('linprog','Display','none'); % Stops linprog from printing


    %size_k = size(W{1});
    %row_k = size_k(1);
    %column_k = size_k(2);

    %zmin_hat_1 = zeros(row_k,1);
    %zmax_hat_1 = zeros(row_k,1);

    %zmin_hat_previous = zmin_hat_1;
    %zmax_hat_previous = zmax_hat_1;

    % ReLU linear approximation is only triangular if zmax_hat_k is positive
    % and zmin_hat_k is negative
    keep_track = 0;
    keep_track2 = {0,46,46+80,46+80+40+38,46+80+40+38+38+19};
    A = [];
    B = [];
    Aeq = [];
    Beq = [];
    ub = [];
    lb = [];

    for k = 2:5

        zmin_hat_previous = lowerbound_hat_cell{k-1};
        zmax_hat_previous = upperbound_hat_cell{k-1};
        size_k = size(W{k});
        row_k = size_k(1);
        column_k = size_k(2);


        %W_k = [W{k},zeros(size_k)];
        %zmin_hat_k = zeros(row_k,1);
        %zmax_hat_k = zeros(row_k,1);

        c1 = zmax_hat_previous./(zmax_hat_previous-zmin_hat_previous);
        c2 = c1.*zmin_hat_previous;

        checkmin = zmin_hat_previous >0;
        checkmax = zmax_hat_previous >0;

        A_individual = [diag(-c1),eye(column_k);eye(column_k),-eye(column_k)];
        B_individual = [-c2;zeros(column_k,1)];
        Aeq_individual = zeros(column_k,column_k*2);
        Beq_individual = zeros(column_k,1);
        lb_individual = [zmin_hat_previous;lowerbound_cell{k-1}];
        ub_individual = [zmax_hat_previous;upperbound_cell{k-1}];

        size_A_individual = size(A_individual);
        row_A_individual =  size_A_individual(1);
        column_A_individual = size_A_individual(2);

        for j = 1:column_k
            if (checkmax(j)==1) && (checkmin(j)==1) == 1    % both positive
                A_individual([j,j+column_k],[j,j+column_k]) = 0;
                B_individual(j) = 0;
                Aeq_individual(j,[j,j+column_k]) = [1, -1];
                lb_individual(j+column_k) = zmin_hat_previous(j);
                ub_individual(j+column_k) = zmax_hat_previous(j);

            elseif (checkmax(j)==0) && (checkmin(j)==0) == 1    % both negative
                A_individual([j,j+column_k],[j,j+column_k]) = 0;
                B_individual(j) = 0;
                Aeq_individual(j,j+column_k) = 1;
                ub_individual(j+column_k) = 0;
                lb_individual(j+column_k) = 0;
            end
        end

        A_layer = [zeros(row_A_individual,keep_track),A_individual,zeros(row_A_individual,274-column_A_individual-keep_track)];
        Aeq_layer = [zeros(height(Aeq_individual),keep_track2{k-1}),W{k-1},-eye(height(W{k-1})),zeros(height(Aeq_individual),280-width(W{k-1})-height(W{k-1})-keep_track2{k-1}); zeros(height(Aeq_individual),6),zeros(height(Aeq_individual),keep_track),Aeq_individual,zeros(height(Aeq_individual),274-column_A_individual-keep_track)];

        A = cat(1,A,A_layer);
        Aeq = cat(1,Aeq,Aeq_layer);
        %B_individual = cat(1,-b{k-1},B_individual);
        B = cat(1,B,B_individual);
        Beq_individual = cat(1,-b{k-1},Beq_individual);
        Beq = cat(1,Beq,Beq_individual);
        ub = cat(1,ub,ub_individual);
        lb = cat(1,lb,lb_individual);

        %if k==4
         %   keep_track = keep_track + 0.5*column_A_individual; % Keep tracks
        %else
        keep_track = keep_track + column_A_individual; % Keep tracks
        %end
    end
    sizeA_final = size(A);
    rowA_final = sizeA_final(1);

    sizeAeq_final = size(Aeq);
    rowAeq_final = sizeAeq_final(1);

    A = cat(2,zeros(rowA_final,6),A);
    %Aeq = cat(2,zeros(rowAeq_final,6),Aeq);

    lb = cat(1,transpose(xmin),lb);
    ub = cat(1,transpose(xmax),ub);

    ymin_variables = linprog([zeros(1,(280-19)),W{5}],A,B,Aeq,Beq,transpose(lb),transpose(ub),options);
    ymax_variables = linprog(-[zeros(1,(280-19)),W{5}],A,B,Aeq,Beq,transpose(lb),transpose(ub),options);
    ymin = [zeros(1,(280-19)),W{5}]*ymin_variables + b{5};
    ymax = [zeros(1,(280-19)),W{5}]*ymax_variables + b{5};

end


