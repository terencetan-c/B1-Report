function [ymin,ymax] = test(W,b,xmin,xmax)


    W_p = max(W{1},0);
    W_n = min(W{1},0);

    xmaxi = transpose(xmax);
    xmini = transpose(xmin);

    z_max = W_p*xmaxi + W_n*xmini + b{1};
    z_min = W_p*xmini + W_n*xmaxi + b{1};

    xmini = max(z_min,0);
    xmaxi = max(z_max,0);

    %
    W_p = max(W{2},0);
    W_n = min(W{2},0);


    z_max = W_p*xmaxi + W_n*xmini + b{2};
    z_min = W_p*xmini + W_n*xmaxi + b{2};

    xmini = max(z_min,0);
    xmaxi = max(z_max,0);

    %
    W_p = max(W{3},0);
    W_n = min(W{3},0);


    z_max = W_p*xmaxi + W_n*xmini + b{3};
    z_min = W_p*xmini + W_n*xmaxi + b{3};

    xmini = max(z_min,0);
    xmaxi = max(z_max,0);

    %
    W_p = max(W{4},0);
    W_n = min(W{4},0);


    z_max = W_p*xmaxi + W_n*xmini + b{4};
    z_min = W_p*xmini + W_n*xmaxi + b{4};

    xmini = max(z_min,0);
    xmaxi = max(z_max,0);

    %
    W_p = max(W{5},0);
    W_n = min(W{5},0);


    ymax = W_p*xmaxi + W_n*xmini + b{5};
    ymin = W_p*xmini + W_n*xmaxi + b{5};
end
   