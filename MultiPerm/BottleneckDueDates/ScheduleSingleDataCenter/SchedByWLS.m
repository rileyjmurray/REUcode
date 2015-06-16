function [DataCenter, dueDates] = SchedByWLS(T, D, W, numSvr)
    % Schedule a DataCenter with numSvr Server's according
    %   to weighted least slack first.
    
    slack = D - T'; % global due date minus local processing time
    DataCenter(numSvr) = Server;
    dueDates = D;
    
    negMetric = W .* (slack .* (slack < 0)); 
    % ^ to sort in increasing order (valid values are nonzero)
    zeroMetric = W .* (slack == 0);
    % ^ to sort in decreasing order (valid values nonzero)
    posMetric = W ./ (slack .* (slack > 0));
    posMetric(posMetric == inf) = 0;
    posMetric(posMetric == -inf) = 0;
    % ^ to sort in decreasing order (valid values are nonzero)
     
    [~, negJobsOrder] = sort(negMetric,'ascend');
    numNeg = sum(negMetric ~= 0);
    [~, zeroJobsOrder] = sort(zeroMetric, 'descend');
    numZero = sum(zeroMetric ~= 0);
    [~, posJobsOrder] = sort(posMetric, 'descend');
    numPos = sum(posMetric ~= 0);
    
    % Schedule jobs with negative slack
    for i = 1:numNeg
        j = negJobsOrder(i);
        nextFrees = vertcat(DataCenter.nextFree);
        firstAvail = find(nextFrees == min(nextFrees),1);
        nextSvr = DataCenter(firstAvail);
        nextSvr.toDo(end + 1) = j;
        nextSvr.nextFree = nextSvr.nextFree + T(j);
        nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
        if (D(j) < nextSvr.completionTimes(end))
            dueDates(j) = nextSvr.completionTimes(end);
        end
    end
    
    % Schedule jobs with zero slack
    for i = 1:numZero
        j = zeroJobsOrder(i);
        nextFrees = vertcat(DataCenter.nextFree);
        firstAvail = find(nextFrees == min(nextFrees),1);
        nextSvr = DataCenter(firstAvail);
        nextSvr.toDo(end + 1) = j;
        nextSvr.nextFree = nextSvr.nextFree + T(j);
        nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
        if (D(j) < nextSvr.completionTimes(end))
            dueDates(j) = nextSvr.completionTimes(end);
        end
    end
    
    % schedule jobs with positive slack
    for i = 1:numPos
        j = posJobsOrder(i);
        nextFrees = vertcat(DataCenter.nextFree);
        firstAvail = find(nextFrees == min(nextFrees),1);
        nextSvr = DataCenter(firstAvail);
        nextSvr.toDo(end + 1) = j;
        nextSvr.nextFree = nextSvr.nextFree + T(j);
        nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
        if (D(j) < nextSvr.completionTimes(end))
            dueDates(j) = nextSvr.completionTimes(end);
        end
    end
    
end