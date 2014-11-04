function S = computeSensitivity(initParams, delta, inputFunc, comparison)
    % Computes the sensitivity to all parameters in the given set
    % 
    %   initParams  - Initial parameter set
    %   delta       - Fraction by which to adjust parameter (+/- delta)
    %   inputFunc   - A function to run the model with. 
    %                 --> must only take parameters as input                (given as row vector)
    %                 --> must return complete time data for one species    (column vector)
    %   comparison  - A string to tell the function how to compute sensitivity
    %                 --> 'steadystate' or 'ss': compare steady state values
    %                 --> 'alltimes' or 'at': compare all values, sum magnitude of comparisons
    %
    % Returns a column vector of sensitivity, where each row is the sensitivity to a parameter
    %   --> Calculated by formula: S = (ki / Y) * (dY / dKi)
    %   --> for 'alltimes' comparison, given as average over whole vector
    
    % Check inputs
    validateattributes(initParams, {'numeric'}, {}, mfilename, 'intiParams', 1);
    validateattributes(delta, {'numeric'}, {'>', 0, '<', 1}, mfilename, 'delta', 2);
    validateattributes(inputFunc, {'function_handle'}, {}, mfilename, 'inputFunc', 3);
    validatestring(comparison, {'steadystate', 'ss', 'alltimes', 'at'}, mfilename, 'comparison', 4);
    
    % Run with normal (reference) parameters
    pRef = initParams;
    yRef = inputFunc(pRef);
    
    % Iterate over all parameters
    S = zeros(length(pRef), 1);
    for i = 1:length(pRef)
        
        % Define new parameter sets
        pHigh = initParams;
        pLow = initParams;
        
        % Change desired parameter by fraction delta
        pHigh(i) = pHigh(i) * (1 + delta);
        pLow(i) = pLow(i) * (1 - delta);

        % Run model w/ modified parameters
        yHigh = inputFunc(pHigh);
        yLow = inputFunc(pLow);
        
        % Compute sensitivity
        switch lower(comparison)
            case {'steadystate', 'ss'}
                S(i) = (yHigh(end) - yLow(end)) / (2 * delta * yRef(end));
            case {'alltimes', 'at'}
                S(i) = mean(abs((yHigh - yLow) ./ (2 * delta * yRef)));
        end
    end
end