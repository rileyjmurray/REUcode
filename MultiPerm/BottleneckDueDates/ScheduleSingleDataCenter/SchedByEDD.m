function [DataCenter, dueDates] = SchedByEDD(T, D, numSvr)
    
    DataCenter(numSvr) = Server;
    dueDates = D;
    [~, jobsOrder] = sort(D,'ascend');
    for i = 1:length(D)
        j = jobsOrder(i);
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