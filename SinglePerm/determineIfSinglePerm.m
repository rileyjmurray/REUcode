function trueOrFalse = determineIfSinglePerm(DataCenters, P)
% Returns true iff DataCenters (a cell array of Server vectors)
%   follows a consistent ordering of job start times
    
    n = size(P,1);
    m = size(P,2);

    % find start time of each job on each DataCenter
    starts = zeros(n,m);
    %   row index : job
    %   column index : DataCenter
    % starts(job, dc) = start time of Job "job" on DataCenter "dc."
    
    % populate starts
    for dc = 1:m
        for svr = 1:length(DataCenters{dc})
            currServer = DataCenters{dc}(svr);
            for jobIdx = 1:length(currServer.toDo)
                job = currServer.toDo(jobIdx);
                starts(job,dc) =...
                    currServer.completionTimes(jobIdx) - P(job, dc);
            end
        end
    end
    
    % is SinglePerm if there exists a single indexing of 1:n which produces a
    % valid sort for all columns
    
    match = 0;
    for dc = 1:m
        [~, currSort] = sort(starts(:,dc));
        for otherDC = 1:m
            if (otherDC ~= dc)
                result = issorted(starts(currSort,otherDC));
                if (~result)
                    break;
                else
                    match = match + 1;
                end
            end
        end
        if (match == m - 1)
                trueOrFalse = true;
                return;
        end
    end
    trueOrFalse = false;
end

