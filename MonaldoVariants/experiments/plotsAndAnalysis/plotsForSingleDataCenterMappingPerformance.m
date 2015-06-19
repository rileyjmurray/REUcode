
load('experiments/mapping_experiment1.mat');

% Outputs(1, trial) = W' * compTimesMkspn';
%    Outputs(2, trial) = W' * compTimesSum';
%    Outputs(3, trial) = W' * compTimesWLPT';

figure;
subplot(2,1,1);
hist(Outputs(1,:) ./ Outputs(3,:),100);
title('Makespan divided by WLPT');
subplot(2,1,2);
hist(Outputs(2,:) ./ Outputs(3,:),100);
title('Sum divided by WLPT');

meanMakespanToWLPT = mean(Outputs(1,:) ./ Outputs(3,:));
meanSumToWLPT = mean(Outputs(2,:) ./ Outputs(3,:));

err = norminv(0.975, 0, 1);
MakespanToWlptCI = [meanMakespanToWLPT ...
    - err * sqrt(var(Outputs(1,:) ./ Outputs(3,:)) / length(Outputs(1,:))),
    meanMakespanToWLPT ...
    + err * sqrt(var(Outputs(1,:) ./ Outputs(3,:)) / length(Outputs(1,:)))]; %#ok<COMNL>

SumToWlptCI = [meanSumToWLPT ...
    - err * sqrt(var(Outputs(2,:) ./ Outputs(3,:)) / length(Outputs(2,:))),
    meanSumToWLPT ...
    + err * sqrt(var(Outputs(2,:) ./ Outputs(3,:)) / length(Outputs(2,:)))]; %#ok<COMNL>

display(sprintf('\n Confidence Intervals for Performance Ratios \n'));
display(sprintf('Makespan Pre-Processing divided by WLPT'));
display(MakespanToWlptCI');
display(sprintf('\n Sum Pre-Processing divided by WLPT'));
display(SumToWlptCI');

display(sprintf('\n Bounds for Performance Ratios \n'));
display(sprintf('Worst case: Makespan Pre-Processing divided by WLPT'));
display(max(Outputs(1,:) ./ Outputs(3,:)));
display(sprintf('\n Worst case: Sum Pre-Processing divided by WLPT'));
display(max(Outputs(2,:) ./ Outputs(3,:)));
display(sprintf('\n BEST case: Makespan Pre-Processing divided by WLPT'));
display(min(Outputs(1,:) ./ Outputs(3,:)));
display(sprintf('\n BEST case: Sum Pre-Processing divided by WLPT'));
display(min(Outputs(2,:) ./ Outputs(3,:)));



