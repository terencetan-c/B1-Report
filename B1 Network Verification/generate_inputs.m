% Generate a k by 6 matrix whose elements are between xmin and xmax
function X = generate_inputs(xmin,xmax,k)
    X = xmin + (xmax-xmin).*rand(k,6);
end
