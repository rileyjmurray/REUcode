function [order, dueDates] = OrderDataCenters(P, W, K, DCO)
% Takes in P, W, K, DCO (DataCenter ordering metric). Returns ...
%   (1) order : a permutation of 1:m in decreasing order of load
%   (2) a vector of due dates for each job on the worst DataCenter

    switch upper(DCO)
        case {'SUM'}
            [order, dueDates] = OrderByWeightedSum(P, W, K);
        case {'NUM_SVR'}
            [order, dueDates] = OrderByNumServers(P, W, K);
    end
end