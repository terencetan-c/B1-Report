function [ymin,ymax] = linear_programming_bound(W,b,xmin,xmax)
    

    xmax = transpose(xmax);
    xmin = transpose(xmin);

    options = optimoptions('linprog','Display','none'); % Stops linprog from printing


    size_k = size(W{1});
    row_k = size_k(1);
    %column_k = size_k(2);

    zmin_hat_1 = zeros(row_k,1);
    zmax_hat_1 = zeros(row_k,1);

    for i = 1:row_k
        zmin_0 = linprog(W{1}(i,:),[],[],[],[],xmin,xmax,options);
        zmax_0 = linprog(-W{1}(i,:),[],[],[],[],xmin,xmax,options);
        zmin_hat_1(i) = W{1}(i,:)*zmin_0 + b{1}(i,:);
        zmax_hat_1(i) = W{1}(i,:)*zmax_0 + b{1}(i,:);
    end

    zmin_hat_previous = zmin_hat_1;
    zmax_hat_previous = zmax_hat_1;
    % ReLU linear approximation is only triangular if zmax_hat_k is positive
    % and zmin_hat_k is negative

    for k = 2:5

        size_k = size(W{k});
        row_k = size_k(1);
        column_k = size_k(2);

        W_k = [W{k},zeros(size_k)];
        zmin_hat_k = zeros(row_k,1);
        zmax_hat_k = zeros(row_k,1);

        c1 = zmax_hat_previous./(zmax_hat_previous-zmin_hat_previous);
        c2 = c1.*zmin_hat_previous;

        checkmin = zmin_hat_previous >0;
        checkmax = zmax_hat_previous >0;

        A = [eye(column_k),diag(-c1);-eye(column_k),eye(column_k)];
        B = [-c2;zeros(column_k,1)];
        Aeq = zeros(column_k,column_k*2);
        Beq = zeros(column_k,1);
        lb = [zeros(column_k,1);zmin_hat_previous];
        ub = [zmax_hat_previous;zmax_hat_previous];

        for j = 1:column_k
            if (checkmax(j)==1) && (checkmin(j)==1) == 1    % both positive
                A([j,j+column_k],[j,j+column_k]) = 0;
                B(j) = 0;
                Aeq(j,[j,j+column_k]) = [1, -1];
                lb(j) = zmin_hat_previous(j);

            elseif (checkmax(j)==0) && (checkmin(j)==0) == 1    % both negative
                A([j,j+column_k],[j,j+column_k]) = 0;
                B(j) = 0;
                Aeq(j,j) = 1;
                ub(j) = 0;
            end
        end

        for i = 1:row_k

            zmin_k = linprog(W_k(i,:),A,B,Aeq,Beq,lb,ub,options);
            zmax_k = linprog(-W_k(i,:),A,B,Aeq,Beq,lb,ub,options);
            zmin_hat_k(i) = W_k(i,:)*zmin_k + b{k}(i,:);
            zmax_hat_k(i) = W_k(i,:)*zmax_k + b{k}(i,:);

        end
        zmin_hat_previous = zmin_hat_k;
        zmax_hat_previous = zmax_hat_k;
    end
    
    ymin = zmin_hat_k;
    ymax = zmax_hat_k;
end

