function Y = computeOutput(params)
    % Given a set of parameters, returns some output
    
    % Make a model for the simple chemical system:
    %   y(1) + y(2) <--> y(3)
    %   kf = p(1)
    %   kr = p(2)
    modelODE = @(t, y, p) ...
        [p(2) * y(3) - p(1) * y(1) * y(2)
         p(2) * y(3) - p(1) * y(1) * y(2)
         p(1) * y(1) * y(2) - p(2) * y(3)];
     
    % Define new tspans and ICs
    tspan = (0:10:6*60) * 60;       % 6 hours by 10 minute intervals
    y0 = [1; 1; 0];
    
    % Simulate system
    [~, yout] = ode15s(modelODE, tspan, y0, [], params);
    
    % Return the amount of product
    Y = yout(:, 3);
end