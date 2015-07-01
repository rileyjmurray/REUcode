function P = TransformCOmKToPDm(P, K)
    % Inputs
    %   K -- a row vector of the number of servers per DataCenter
    %   P -- a matrix of processing times for jobs on each DataCenter
    %       P(j,dc) is the processing time for Job j on DataCenter dc

    % Details of the transformation
    %   Get the maximum processing time for each job
    %   Define a new DataCenter for each job where the only nonzero
    %       demand on that DataCenter is the maximum processing time 
    %       for the associated job.
    %   Append the resultant matrix to P
    %   Divide do element-by-element division of processing times
    %       by the number of servers at each DataCenter
    
    % Consequences of the transformation
    %   If Monaldo solves the LP (by finding the optimal solution to the
    %   given dual, rather than merely a feasible solution),
    %   then we are garunteed a three approximation by the list schedule
    %   that Monaldo specifies.
    
    n = size(P,1);
    K = repmat([K, ones(1, n)], n, 1);
    maxSteps = max(P,[],2);
    P = [P, diag(maxSteps)];
    P = P ./ K;
   
end