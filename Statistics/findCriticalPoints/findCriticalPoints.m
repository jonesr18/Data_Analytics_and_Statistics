function points = findCriticalPoints(curve, type)
    % Curve is the set of points you wish to find the local minima or maxima over
    % type is a string stating 'min', 'max', or 'both'
    % - if 'both', the function will return a cell array where points{1} === the maxPoints 
    %   array and points{2} === the minPoints array. Otherwise the function will directly
    %   return the vector of points. The points are given as indexes corresponding with
    %   minumum and/or maxumum local values.
    
    % Check inputs
    type = lower(type);
    validateattributes(curve, {'numeric'}, {'1D'}, mfilename, 'curve', 1);
    validatestring(type, {'min', 'max', 'both'}, mfilename, 'type', 2);
    
    % Differentiate curve to find where dCurve = 0
    dCurve = diff(curve);
    
    % Normalize dCurve to be +/- 1 or NaN if 0.
    dcNorm = dCurve ./ abs(dCurve);
    criticalPoints = diff(dcNorm);
    
    % Find requested points and build output
    switch type
        case 'min'
            minPoints = find(criticalPoints == 2) + 1;     % The +1 adjusts for the diff funcs used
            points = minPoints;
        case 'max'
            maxPoints = find(criticalPoints == -2) + 1;
            points = maxPoints;
        case 'both'
            minPoints = find(criticalPoints == 2) + 1;
            maxPoints = find(criticalPoints == -2) + 1;
            points = {maxPoints, minPoints};
        otherwise
            error('Type is not correct somehow')
    end
end