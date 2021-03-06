function sigma = ModifiedMonaldo(K,P,W)
    
    tol = 1.e-10;
    % problem: CPm | 1 | \sum_{j} W_j * C_j

    % Inputs:
    %
    % P = matrix of processing times, 
    %   one job per row
    %   one datacenter per column (because one datacenter per task)
    % *** OR *** P = one-by-three vector
    %               P(1) = number of jobs,
    %               P(2) = number of datacenters, 
    %               P(3) = maximum processing time (used in discrete 
    %                   uniform distribution)
    %
    % W = weights
    %
    % K = a vector of number of servers for each DataCenter.
    %   K(dc) is the number of servers on DataCenter "dc."
    
    % outputs
    %
    % sigma = the order in which jobs will be post processed.
    
    if (size(P,1) == 1 && size(P,2) == 3)
        P = randi([1,P(3)],P(1),P(2));
    end
    
    n = size(P,1);
    sigma = zeros(1,n);
    scheduled = zeros(n,1);
    ratio = zeros(2,n);
    ratio(2,:) = 1:n;
    
    L = sum(P,1) ./ K;
    w = W;
    for idx = 1:n
        k = n - idx + 1;
        mu = find((L == max(L)),1);
        ratio(1,:) = w ./ P(:,mu);

        [~, c] = find(...
            ratio(1,scheduled == 0) == min(ratio(1,scheduled == 0)),1);
        temp = ratio(:,scheduled == 0);
        sigma(k) = temp(2,c);
        
        theta = w(sigma(k)) / P(sigma(k),mu);
        w(scheduled == 0) = w(scheduled == 0) ...
            - theta * P(scheduled == 0, mu);
        w(w < 0 & w > -tol) = 0;
        L = L - P(sigma(k),:) ./ K;
        scheduled(sigma(k)) = 1;
    end
end