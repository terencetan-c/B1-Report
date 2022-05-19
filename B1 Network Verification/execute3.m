folder = '/Users/terencetan/Documents/MATLAB/B1 Network Verification';
filelist = dir(fullfile(folder, '*.mat'));
k_max = 100;
time = zeros(1,k_max);

    
for k = 1:1:k_max
    for fidx=1:numel(filelist)
        X=load(fullfile(filelist(fidx).folder, filelist(fidx).name));
        %stop_time=0;
        tic
        for j = 1:10000
            
            input = generate_inputs(X.xmin,X.xmax, k);
            input = transpose(input);
            
            compute_nn_outputs(X.W, X.b, input);
            %stop_time = stop_time + toc;
        end
        time(k) = time(k) + toc/10000;        
    end
end

plot(1:k_max,time./500)
title('Average amount of time taken to generate outputs against k');
xlabel('value of k');
ylabel('average amount of time taken to generate outputs (seconds)');
grid on