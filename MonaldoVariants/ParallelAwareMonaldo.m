function sigma = ParallelAwareMonaldo(K,P,W)
    
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
    % sigma = the order in which jobs will be list scheduled.
    
    if (size(P,1) == 1 && size(P,2) == 3)
        P = randi([1,P(3)],P(1),P(2));
    end
    
    n = size(P,1);
    m = size(P,2);
    sigma = zeros(1,n);
    scheduled = zeros(n,1);
    ratio = zeros(2,n);
    ratio(2,:) = 1:n;
    L = sum(P,1) ./ K;
    
    w = W;
    for idx = 1:n
        k = n - idx + 1;
        
        currLastPropTime = 0;
        for dc = 1:m

        %   find the "proposed job" (job with min wt-to-proc-time ratio.)
        %
            ratio(1,:) = w ./ P(:,dc);
            unsched = ratio(:,scheduled == 0);
            [~, c] = find(unsched(1,:) == min(unsched(1,:)),1);
            propJob = unsched(2,c);
                
        %   find the latest completion time if the proposed job was
        %   scheduled now (sum of all other jobs competion times,
        %   divided by number of servers, then plus proposed job proc-time)
        %       
            otherJobIndicies = setdiff(1:n,...
                [ratio(2, scheduled == 1), propJob]);
            otherProcTimes = P(otherJobIndicies, dc);
            propTime = sum(otherProcTimes) / K(dc) + ...
                P(propJob, dc);
                
        %   if the Latest completion time for the current DataCenter is
        %   less than the existing "proposed" latest completion time,
        %       update both the "proposed" latest completion time and the
        %       DataCenter associated with it.
        
            if (propTime > currLastPropTime || (idx == n && dc == m))
               currLastPropTime = propTime;
               mu = dc;
               sigma(k) = propJob;
            end
        end
        if (P(sigma(k),mu) > 0)
            theta = w(sigma(k)) / P(sigma(k),mu);
        end
        w(scheduled == 0) = w(scheduled == 0) ...
            - theta * P(scheduled == 0, mu);
        w(w < 0 & w > -tol) = 0;
        L = L - P(sigma(k),:) ./ K;
        scheduled(sigma(k)) = 1;
    end
end