%% Goal: determine if pre-processing performs worse than Monaldo a higher prop
% ortion of the time when job-tasks are:
%       on different servers on some dataCenter, and...
%       the same server on another DataCenter.
% In order to determine how significant this "lack of coordination" is
%   for pre-processing with min-makespan.

%%
load('experiments/c3h1.mat');
% Outputs(1,:) - obj of mod
% Outputs(2,:) - obj of Pre
% Outputs(3,:) - obj of Awk

%%
myRat = Outputs(1,:) ./ Outputs(2,:);
hist(Outputs(1,:) ./ Outputs(2,:),200);
mod2preMean = mean(Outputs(1,:) ./ Outputs(2,:));
preWorseIdx = (Outputs(1,:) < Outputs(2,:));
mid = median(myRat(preWorseIdx));
muchWorseIdx = (myRat < mid);
littleWorseIdx = (myRat >= mid & myRat < 1.0);
%% Have trials where things went bad.

% now want to quantify lack of cooperation and s