function [DataCenters, jobCompletionTimes] = GreedilyFollowOrdering(K,P,C)
    
    % problem: CPm | k , prec | \sum_{j} C_j

    % Inputs:
    % K = number of servers per datacenter
    % P = matrix of processing times, 
    %   one job per row
    %   one datacenter per column (because one datacenter per task)
    % *** OR *** P = one-by-three vector
    %   P(1) = number of jobs,
    %   P(2) = number of datacenters, 
    %   P(3) = maximum processing time (used in discrete uniform
    %   distribution)
    % C = ordering constraint. Jobs will be scheduled in order C(1),
    %   C(2),..., C(n)

    % Output:
    % D = 3 dimensional matrix
    %   first dimension be datacenter
    %   second dimension be servers
    %   third dimension be job / task
    %
    % objVal = objective function value (sum C_j)
    
    if (size(P,1) == 1 && size(P,2) == 3)
        P = randi([0,P(3)],P(1),P(2));
    end

    n = size(P,1);
    m = size(P,2);
    jobCompletionTimes = zeros(1,n);
    for dc = 1:m
        DataCenters{dc}(K(dc)) = Server;
        for j = 1:n
            nextFrees = vertcat(DataCenters{dc}.nextFree);
            firstAvail = find(nextFrees == min(nextFrees),1);
            nextSvr = DataCenters{dc}(firstAvail);
            idx = length(nextSvr.toDo) + 1;
            nextJob = C(j);
            nextSvr.nextFree = nextSvr.nextFree + P(nextJob, dc);
            nextSvr.toDo(idx) = nextJob;
            nextSvr.completionTimes(idx) = nextSvr.nextFree;
            if (jobCompletionTimes(j) < nextSvr.completionTimes(idx))
                jobCompletionTimes(j) = nextSvr.completionTimes(idx);
            end
        end  
    end 
end