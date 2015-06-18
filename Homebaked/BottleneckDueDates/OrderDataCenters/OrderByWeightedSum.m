function [order, dueDates] = OrderByWeightedSum(...
    P, W, K, sortOrder)
    n = size(P,1);
    m = size(P,2);
    weightedSum = zeros(1,m);
    dueDates = zeros(m, n);
    for i = 1:length(weightedSum)
        [~, dueDates(i,:)] = SchedByWLPT(P(:,i), W, K(i));
        weightedSum(i) = W * dueDates(i,:)'; % dot product
    end
    [~, order] = sort(weightedSum, sortOrder);
    dueDates = dueDates(order(1), :);
end