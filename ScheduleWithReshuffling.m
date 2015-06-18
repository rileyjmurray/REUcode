function [DataCenters, jobCompletionTimes] = ScheduleWithReordering(K,P,C)
    
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
            nextSvr.toDo(end + 1) = nextJob; % append nextJob
            nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
            if (jobCompletionTimes(j) < nextSvr.completionTimes(end))
                jobCompletionTimes(j) = nextSvr.completionTimes(end);
            end
        end  
    end % schedule finished
    
    %% Begin reordering 
    % Note: DCs is an abbreviation for DataCenters
    
    unassigned = 1:n;
    while size(unassigned,2) > 0
        
        % Find job j in unassigned with latest completion time C_j in DCs
        makespan = zeros(1,m);
        for dc = 1:m
            nextFrees = vertcat(DataCenters{dc}.nextFree);
            makespan(dc) = max(nextFrees);
        end
        Cj = max(makespan); % C_j is the latest completion time
        CjDC = find(makespan == Cj,1); % Datacenter of C_j
        j = DataCenters{CjDC}.toDo(end); % Job j completes at C_j
        
        % Make sure j is in unassigned
        while sum(unassigned == j) == 0
            makespan = makespan(makespan ~= Cj);
            Cj = max(makespan);
            CjDC = find(makespan == Cj,1);
            j = DataCenters{CjDC}.toDo(end);
        end
        
        for dc = 1:m
            for svr = 1:K(dc)
                jobs = DataCenters{dc}(svr).toDo; % for brevity's sake
                cTimes = DataCenters{dc}(svr).completionTimes;
                
                if sum(jobs == j) == 1 % j is on that server
                    jIndex = find(jobs == j,1);
                    if cTimes(jIndex) ~= Cj % j does not complete at C_j
                        % Rearrange on server so that j completes at C_j
                        
                        % job being processed at time C_j
                        targetJobIdx = find(CTimes >= Cj,1);
                        
                        % for all jobs inbetween j and this job
                        for i = jIndex+1:targetJobIdx
                            Ji = jobs(i);
                            if sum(unassigned == Ji) ~= 0 % if unassigned
                                if cTimes(i)+ P(j,dc) <= Cj % swap?
                                     % jobs to be switched
                                     [DataCenters{dc}(svr).toDo,...
                                         DataCenters{dc}(svr).completionTimes]...
                                         = swap(jobs,cTimes,j,Ji);
                                end
                            end
                        end
                    end
                end
            end
        end
        unassigned = unassigned(unassigned~=j); % j is now assigned
        
    end
    
    for dc = 1:m
        for svr = 1:K(dc)
            [DataCenters{dc}(svr).toDo, DataCenters{dc}(svr).completionTimes]...
            = killGaps(dc,DataCenters{dc}(svr).toDo,...
            DataCenters{dc}(svr).completionTimes);
        end
    end
    
end

function [toDo, completionTimes] = swap(dc,toDo,completionTimes,j1,j2)
    index1 = find(toDo == j1,1);
    index2 = find(toDo == j2,1);
    toDo(index1) = j2;
    toDo(index2) = j1;
    [toDo, completionTimes] = killGaps(dc,toDo,completionTimes); % might change later
end

function [toDo, completionTimes] = killGaps(dc,toDo,completionTimes)
    completionTimes(1) = P(toDo(1),dc);
    for j = 2:size(toDo) % schedules purely based on processing times of jobs
        completionTimes(j) = completionTimes(j-1)+P(toDo(j),dc);
    end
end