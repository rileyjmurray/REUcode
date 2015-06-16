function [Pmapped, mapping] = preProcMinMakespan(P, K)
    % Inputs
    %
    % P = matrix of processing times, 
    %   one job per row
    %   one datacenter per column (because one datacenter per task)
    %
    % K = vector. K(dc) is number of servers on DataCenter "dc."
    
    % Outputs
    %
    % Pmapped = matrix of processing times after mapping servers to
    % DataCenters. Processing times on a "DataCenter" in Pmapped will equal
    % zero unless the job is assigned to the server that that "DataCenter"
    % represents.
    %
    % mapping = a cell array of vectors. mapping{dc} is a vector containing
    % the indicies of the "DataCenters" to which the servers were mapped.
    % mapping{dc}(1), ... , mapping{dc}(num_servers_on_dc) are the columns
    % in Pmapped representing these "DataCenters."
    
    % define Pmapped.
    numPsuedoDC = sum(K);
    numDC = size(P,2);
    numJobs = size(P,1);
    Pmapped = zeros(numJobs, numPsuedoDC);
    mapping = cell(numDC,1);
    
    % For each DataCenter, solve Pk || C_max with the LPT (longest
    % processing time) rule.
    %       once solved (or as-solving), enter processing times into
    %       Pmapped.
    currPsuedoDC = 1;
    for dc = 1:numDC
        [~, dcIdx] = sort(P(:,dc), 'descend'); % process jobs by LPT
        psuedoDataCenterCompletionTimes = zeros(1,K(dc));
        mapping{dc} = currPsuedoDC:(currPsuedoDC + (K(dc) - 1));
        currPsuedoDC = currPsuedoDC + K(dc);
        for job = 1:numJobs
            % fetch the next job
            nextJob = dcIdx(job);
            % find the next free "DataCenter"
            nextPsuedoDC = find(psuedoDataCenterCompletionTimes ==...
                min(psuedoDataCenterCompletionTimes),1);
            % schedule the current job on this "DataCenter"
            psuedoDataCenterCompletionTimes(nextPsuedoDC) = ...
                psuedoDataCenterCompletionTimes(nextPsuedoDC) +...
                P(nextJob,dc);
            % update Pmapped
            Pmapped(nextJob, mapping{dc}(nextPsuedoDC)) = P(nextJob,dc);
        end  
    end
end

