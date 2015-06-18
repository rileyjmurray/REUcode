function [DataCenter, dueDates] = SchedByWLPT(T, W, numSvr)
    ratio = W' ./ T;
    DataCenter(numSvr) = Server;
    dueDates = zeros(1,length(ratio));
    [~, jobsOrder] = sort(ratio, 'ascend');
    for i = 1:length(ratio)
        j = jobsOrder(i);
        nextFrees = vertcat(DataCenter.nextFree);
        firstAvail = find(nextFrees == min(nextFrees),1);
        nextSvr = DataCenter(firstAvail);
        nextSvr.toDo(end + 1) = j;
        nextSvr.nextFree = nextSvr.nextFree + T(j);
        nextSvr.completionTimes(end + 1) = nextSvr.nextFree;
        dueDates(j) = nextSvr.completionTimes(end);
    end
end