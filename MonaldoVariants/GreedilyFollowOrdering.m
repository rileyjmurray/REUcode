function [DataCenters, jobCompletionTimes] = GreedilyFollowOrdering(K,P,C)
    
    % problem: CPm | K | \sum_{j} C_j

    % Inputs:
    %
    % K = number of servers per datacenter
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
    % C = ordering constraint. Jobs will be scheduled in order C(1),
    %   C(2),..., C(n)

    % Output:
    %
    % DataCenters = a cell array. DataCenters{dc} is the set of servers at
    % DataCenter "dc." The set of servers is size 1-x-K(dc). A given server
    % is referenced by DataCenters{dc}(svr).
    %
    % jobCompletionTimes = vector. jobCompletionTimes(j) is the time at
    % which job "j" completes.
    
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
            nextJob = C(j);
            nextSvr.nextFree = nextSvr.nextFree + P(nextJob, dc);
            nextSvr.toDo(end + 1) = nextJob;
            nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
            if (jobCompletionTimes(nextJob) < nextSvr.completionTimes(end))
                jobCompletionTimes(nextJob) = nextSvr.completionTimes(end);
            end
        end  
    end 
end