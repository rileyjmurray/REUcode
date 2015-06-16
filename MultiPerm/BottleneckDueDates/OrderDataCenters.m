function [order, dueDates] = OrderDataCenters(P, W, K, DCO)
% Takes in P, W, K, DCO (DataCenter ordering metric). Returns ...
%   (1) order : a permutation of 1:m in decreasing order of load
%   (2) a vector of due dates for each job on the worst DataCenter

    switch upper(DCO)
        case {'SUM_D'}
            [order, dueDates] = OrderByWeightedSum(...
                P, W, K, 'descend');
        case {'SUM_A'}
            [order, dueDates] = OrderByWeightedSum(...
                P, W, K, 'ascend');
        case {'NUM_SVR'}
            [order, dueDates] = OrderByNumServers(P, W, K);
    end
    
end