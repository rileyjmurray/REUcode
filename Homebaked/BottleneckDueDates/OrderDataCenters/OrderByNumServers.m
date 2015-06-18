function [order, dueDates] = OrderByNumServers(P, W, K)
    [~, order] = sort(K,'ascend');
    [~, dueDates] = SchedByWLPT(P(:,order(1)), W, K(order(1)));
end