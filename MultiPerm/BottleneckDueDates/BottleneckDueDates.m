function [DataCenters, comp] = BottleneckDueDates(P, W, K, DCO,...
    dispatch)
% Takes in P, W, K, returns DataCenters and completion time
%   for each job

% Preliminaries
    m = size(P,2);
    [dcOrder, dueDates] = OrderDataCenters(P, W, K, DCO);
    DataCenters = cell(1,m);

% Main: Loop through all DataCenters in order
    for i = 1:m
        dc = dcOrder(i);
        [DataCenter, dueDates] = ...
            ScheduleNextDataCenter(...
            P(:,dc), dueDates, W, K(dc), dispatch);
        DataCenters{dc} = DataCenter;
    end
    comp = dueDates;
end