function [DataCenters, compTimes] = ForwardWorstOp(K, P, W)
    
    if (size(P,1) == 1 && size(P,2) == 3)
        P = randi([1,P(3)],P(1),P(2));
    end
    
    n = size(P,1);
    m = size(P,2);
    sigma = zeros(1,n);
    scheduled = zeros(n,1);
    compTimes = zeros(n,1);
    
    for i = 1:m
        DataCenters{i}(K(i)) = Server;
    end
    
    for k = 1:n
        % get next-available times of each DataCenter
        nextFrees = vertcat(DataCenters{1}.nextFree);
        latestStart = min(nextFrees); % initialize
        bottleNeckDC = 1; % initialize
        for dc = 2:m
            nextFrees = vertcat(DataCenters{dc}.nextFree);
            localLatest = min(nextFrees);
            if (latestStart < localLatest)
               latestStart = localLatest;
               bottleNeckDC = dc;
            end
        end
        ratio = W ./ P(:,bottleNeckDC);
        if (k > 1)
            ratio(scheduled == 1) = Inf;
        end
        sigma(k) = find((ratio == min(ratio)),1);
        % schedule this job
        for dc = 1:m
            nextFrees = vertcat(DataCenters{dc}.nextFree);
            firstAvail = find(nextFrees == min(nextFrees), 1);
            nextSvr = DataCenters{dc}(firstAvail);
            nextSvr.toDo(end + 1) = sigma(k);
            nextSvr.nextFree = nextSvr.nextFree + P(sigma(k), dc);
            nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
            if (compTimes(sigma(k)) < nextSvr.completionTimes(end))
                compTimes(sigma(k)) = nextSvr.completionTimes(end);
            end
        end
        scheduled(sigma(k)) = 1;
    end
end