function sigma = Monaldo(P,W)

    tol = 1.e-10;
    
    % problem: CPm | 1 | \sum_{j} W_j * C_j

    % Inputs:
    %
    % P = matrix of processing times, 
    %   one job per row
    %   one datacenter per column (because one datacenter per task)
    % *** OR *** P = one-by-three vector
    %   P(1) = number of jobs,
    %   P(2) = number of datacenters, 
    %   P(3) = maximum processing time (used in discrete uniform
    %   distribution)
    %
    % W = weights
    
    % outputs
    %
    % sigma = the order in which jobs will be post processed.
    
    if (size(P,1) == 1 && size(P,2) == 3)
        P = randi([1,P(3)],P(1),P(2));
    end
    
    n = size(P,1);
    m = size(P,2);
    sigma = zeros(1,n);
    scheduled = zeros(n,1);
    ratio = zeros(2,n);
    ratio(2,:) = 1:n;
    
    L = sum(P,1);
    w = W;
    for idx = 1:n
        k = n - idx + 1;
        mu = find((L == max(L)),1);
        ratio(1,:) = w ./ P(:,mu);
        
        % now find the column of ratio(2,:) such that
            % (1) this column is for a job which is not yet scheduled
            % (2) this column is for a the unscheduled job with least ratio
        [~, c] = find(...
            ratio(1,scheduled == 0) == min(ratio(1,scheduled == 0)),1);
        temp = ratio(:,scheduled == 0);
        sigma(k) = temp(2,c);
        
        theta = w(sigma(k)) / P(sigma(k),mu);
        w(scheduled == 0) = w(scheduled == 0) ...
            - theta * P(scheduled == 0, mu);
        w(w < 0 & w > -tol) = 0;
        L = L - P(sigma(k),:);
        scheduled(sigma(k)) = 1;
    end
end