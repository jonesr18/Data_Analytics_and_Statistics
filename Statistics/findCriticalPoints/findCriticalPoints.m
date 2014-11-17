function varargout = findCriticalPoints(curve, varargin)
    % Curve is the set of points you wish to find the local minima or maxima over
    % The optional argument specifies what points to return
    % - 'max': local maxima (default)
    % - 'min': local minima 
    % - 'mid': points closest to the average value
    % - 'all': all options
    % - If multiple points are requested, the function will return a cell array where 
    %   each element is the vector of points of a requested type in the order requested. 
    %    o eg:
    %      points = findCriticalPoints(curve, 'max', 'min')
    %      [maxPoints, minPoints] = points{:};
    % - If a single type of point is requested, the function will directly
    %   return the vector of points. 
    % - The points are given as indexes corresponding with minumum and/or maxumum local values.
    
    % Default
    type = {'max'};
    allTypes = {'max', 'min', 'mid'};
    
    % Check inputs
    validateattributes(curve, {'numeric'}, {'1D'}, mfilename, 'curve', 1);
    if nargin > 1
        type = cell(1, numel(varargin));
    end
    for i = 1:numel(varargin)
        arg = lower(varargin{i});
        validatestring(arg, {'max', 'min', 'mid', 'all'}, mfilename, 'varargin', i + 1);
        if strcmpi(arg, 'all')
            type = allTypes;
            break
        end
        type{i} = arg;
    end
    
    % Differentiate if finding min/max points
    if any(strcmpi(type, 'min')) || any(strcmpi(type, 'max'))
        
        % Differentiate curve to find where dCurve = 0
        dCurve = diff(curve);

        % Normalize dCurve to be +/- 1 or NaN if 0.
        dcNorm = dCurve ./ abs(dCurve);
        criticalPoints = diff(dcNorm);
    end
    
    % Bisect if finding mid points
    if any(strcmpi(type, {'mid'}))
        
        % Adjust curve by mean value
        midCurve = curve - mean(curve);
        
        % Normalize midCurve to be +/- 1 or NaN if 0.
        mcNorm = midCurve ./ abs(midCurve);
        criticalMid = diff(mcNorm);
    end
    
    % Find requested points and build output
    varargout = cell(1, numel(type));
    for i = 1:numel(type)
        switch type{i}
            case 'max'
                maxPoints = find(criticalPoints == -2) + 1;
                varargout{i} = maxPoints;
            case 'min'
                minPoints = find(criticalPoints == 2) + 1; % The +1 adjusts for the diff funcs used
                varargout{i} = minPoints;
            case 'mid'
                midPoints = find(abs(criticalMid) == 2);
                varargout{i} = midPoints;
            otherwise
                error('Type is not correct somehow')
        end
    end
end