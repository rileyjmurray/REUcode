function violation = All2NMinus1ConstraintsSatisfied(P, K, compTimes)

    % P = matrix of processing times
    % K = vector of number of servers per DC
    % compTimes = matrix of completion times
    %   each row is a job
    %   each column is completion time at a given DC
    
    n = size(P,1);
    m = size(P,2);
    violation = zeros(m, 2^n - 1);
    
    for dc = 1:m
        for i = 1:(2^n-1)
            str = dec2bin(i, n);
            set = logical(str - '0');
            mySum = sum(P(set,dc));
            mySqSum = sum(P(set,dc).^2);
            myRHS = 0.5 * (mySum^2 / K(dc) + mySqSum);
            myLHS = P(set,dc)' * compTimes(set,dc);
            violation(dc,i) = myRHS - myLHS;
        end
    end

end