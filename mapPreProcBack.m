function [DataCenters, compTimes] = mapPreProcBack(sigma, mapping, Pmapped)
    % inputs
    %
    % sigma = the permutation in which Monaldo schedules a transformed
    % instance of CPm | K | \sum w_j * C_j
    %
    % mapping = a cell array of vectors (one vector for each DataCenter in
    % the original problem). mapping{dc}(svr) contains the column index of
    % Pmapped corresponding to server "svr" of DataCenter "dc."
    %
    % Pmapped = the matrix of processing times used as an input to Monaldo.
    
    % Outputs
    %
    % DataCenters = the solution to CPm | K | \sum w_j * C_j in terms of
    % the original problem.
    %
    % compTimes = a vector of job completion times. Take the dot product of
    % this vector and W to get the objective function value for CPm | K |
    % \sum w_j * C_j
    K = ones(1,size(Pmapped,2));
    [PsuedoDataCenters, compTimes] = GreedilyFollowOrdering(K, Pmapped,...
        sigma);
    psdIdx = 1;
    for i = 1:length(mapping);
        DataCenters{i}(length(mapping{i})) = Server;
        for j = 1:length(mapping{i})
            DataCenters{i}(j) = PsuedoDataCenters{psdIdx}(1);
            psdIdx = psdIdx + 1;
        end
    end
end