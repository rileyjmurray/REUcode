function [DataCenter, dueDates] = ScheduleNextDataCenter(...
    T, D, W, numSvr, policy)
% Takes in T (column of P), W, numSvr (K(column idx of P)),
%   and policy (a string indicating the dispatching technique
%   used in the scheduling)
%   returns a DataCenter scheduled to minimize sum of weighted
%   tardiness, and the new dueDates

    switch upper(policy)
        case {'W-EDD'}
            [DataCenter, dueDates] = SchedByWEDD(T, D, W, numSvr);
        case {'EDD'}
            [DataCenter, dueDates] = SchedByEDD(T, D, numSvr);
        case {'LS'}
            [DataCenter, dueDates] = SchedByWLS(T, D, W, numSvr);
        case {'WLPT'}
            [DataCenter, dueDates] = SchedByWLPT(T, W, numSvr);
        otherwise
            display(sprintf(strcat(...
                '\n ERROR: Scheduling policy for the next',...
                ' DataCenter was not specified or was invalid.',...
                ' \n \n Given policy: ', policy)));
    end
    dueDates = max(D, dueDates);
end