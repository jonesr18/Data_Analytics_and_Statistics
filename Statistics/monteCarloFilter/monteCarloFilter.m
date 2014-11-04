function [passParams, passScores] = monteCarloFilter(initParams, delta, inputFunc, N, criteria, comparison)
    % Computes the partial correlation coefficient for all parameters in the given set
    % 
    %   initParams  - Initial parameter set
    %   delta       - Fraction by which to adjust parameter (+/- delta)
    %   inputFunc   - A function to run the model with 
    %                 --> must only take parameters as input                (given as row vector)
    %                 --> must return complete time data for one species    (column vector)
    %   N           - Number of iterations to perform
    %   criteria    - Cutoff value to filter Monte Carlo simulation results with (low pass)
    %   comparison  - A string to tell the function how to compute sensitivity
    %                 --> 'steadystate' or 'ss': compare steady state values
    %                 --> 'alltimes' or 'at': compare all values, sum magnitude of comparisons
    %
    % Returns the parameter sets that passed the criteria and their score for reference
    %   --> for 'steadystate' comparison, computed from output ss / reference ss
    %   --> for 'alltimes' comparison, computed from RMS difference from reference parameter output
    
    % Check inputs
    validateattributes(initParams, {'numeric'}, {}, mfilename, 'intiParams', 1);
    validateattributes(delta, {'numeric'}, {'>', 0, '<', 1}, mfilename, 'delta', 2); 
    validateattributes(inputFunc, {'function_handle'}, {}, mfilename, 'inputFunc', 3);
    N = round(N);
    validateattributes(N, {'numeric'}, {'positive'}, mfilename, 'N', 4);
    validateattributes(criteria, {'numeric'}, {'nonnegative'}, mfilename, 'constriant', 5);
    validatestring(comparison, {'steadystate', 'ss', 'alltimes', 'at'}, mfilename, 'comparison', 6);
    
    % Run with normal (reference) parameters
    pRef = initParams;
    yRef = inputFunc(pRef);
    
    % Run Monte Carlo simulations (40,000 for best practice)
    pMC = zeros(N, length(pRef));
    scores = zeros(N, 1);
    for i = 1:N
        
        % Randomly range parameters from 10^-2 : 10^2 * thier original value
        randomVector = 10 .^ (-2 + (2 + 2) * rand(length(pRef), 1));
        pMC(i, :) = pRef' .* randomVector;
        yMC = inputFunc(pMC(i, :));
        
        % Calculate scores
        switch lower(comparison)
            case {'steadystate', 'ss'}
                scores(i) = yMC(end) / yRef(end);
            case {'alltimes', 'at'}
                scores(i) = rms(yMC - yRef);
        end
    end
    
    % Extract parameter sets which pass given constraint
    passIdx = scores < criteria;     % Logical vector for indexing
    passParams = pMC(passIdx, :);
    passScores = scores(passIdx);
end
