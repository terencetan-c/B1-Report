folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));
k_max = 100;
time = zeros(1,k_max);

    
for k = 1:1:k_max
    for fidx=1:numel(filelist)
        X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
        input = generate_inputs(X.xmin,X.xmax, k);
        input = transpose(input);
        tic
        compute_nn_outputs(X.W, X.b, input);
        time(k) = time(k) + toc;        
    end
end

plot(1:k_max,time./500)