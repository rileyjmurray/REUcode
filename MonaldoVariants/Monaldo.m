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
    sigma = zeros(1,n);
    scheduled = zeros(n,1);
    
    L = sum(P,1);
    w = W;
    for idx = 1:n
        k = n - idx + 1;
        mu = find((L == max(L)),1);
        ratio = w ./ P(:,mu);
        if (idx > 1)
            ratio(scheduled == 1) = Inf;
        end
        if (ratio == Inf)
            display(strcat(...
            'ERROR -- remaining unscheduled jobs have zero',...
            ' processing time'));
        end
        sigma(k) = find((ratio == min(ratio)),1);
        theta = w(sigma(k)) / P(sigma(k),mu);
        w(scheduled == 0) = w(scheduled == 0) ...
            - theta * P(scheduled == 0, mu);
        w(w < 0 & w > -tol) = 0;
        L = L - P(sigma(k),:);
        scheduled(sigma(k)) = 1;
    end
end