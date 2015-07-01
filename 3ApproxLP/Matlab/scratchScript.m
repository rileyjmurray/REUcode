% double[][] testP = {{3,4,6},{8,6,3},{6,3,7},{0,7,5},{2,5,8},{8,6,4},{1,1,5},{8,4,2}};
% 		int[] testServers = {2,1,1};
% 		double[] testWeights = {1,2,3,1,2,3,1,2};

P = [3,4,6; 8,6,3; 6,3,7; 0,7,5; 2,5,8; 8,6,4; 1,1,5; 8,4,2];
K = [2,1,1];
W = [1,2,3,1,2,3,1,2]';

sigma = ParallelAwareMonaldo(K, P, W);
[~, compTimes] = GreedilyFollowOrdering(K, P, sigma);
obj = W' * compTimes';

%% determine if missing a constraint

% violation = All2NMinus1ConstraintsSatisfied(P, K, compTimes)
% need: P, K, compTimes

P = Pcollec{bad(1)};
K = Kcollec{bad(1)};
W = Wcollec{bad(1)};

% compTimes is from the LP. "CT"
violations = All2NMinus1ConstraintsSatisfied(P,K,CT);
% [47.73913043478261, 47.73913043478261]
% [8.0, 8.0]
% [83.0, 83.0]
% [5112.291666666667, 1124.2694099378882]
% [42.0, 42.0]
% [49.0, 49.0]
% [23.0, 23.0]
% [48.0, 48.0]
% [18.0, 18.0]
% [46.0, 46.0]
% [39.0, 39.0]
% [10.0, 10.0]
% [42.0, 42.0]
% [45.0, 45.0]
% [41.0, 41.0]
% [37.0, 37.0]
% [1836.1707317073171, 376.92307692307685]
% [46.0, 46.0]
% [28.0, 28.0]
% [42.0, 2.0]

%%
figure;
subplot(2,1,1);
stem(violations(1,:));
subplot(2,1,2);
stem(violations(2,:));

%%
figure
subplot(3,1,1);
stem(ObjectiveOutputs(1,lpFinished) ./ lowerBound(lpFinished));
title('Parallel Aware Monaldo Optimality Gap');
ylim([1,1.3]);

subplot(3,1,2);
stem(ObjectiveOutputs(2, lpFinished) ./ lowerBound(lpFinished));
title('3-Approx LP Optimality Gap');
ylim([1,1.3]);

subplot(3,1,3);
stem(ObjectiveOutputs(2, lpFinished) ./ ObjectiveOutputs(1, lpFinished));
title('3-Approx / Parallel Aware Monaldo');
ylim([0.95,1.1]);

%%

% from "compareThreeHueristics_randK_randW.m"
%  Outputs(1, trial) = W' * compTimesTrans';
%  Outputs(2, trial) = W' * compTimesSum';

figure
low = 0.9;
high = 1.05;
v = unique(ProblemSpecs(:,1));


subplot(5,1,1);
set = find(ProblemSpecs(:,1) == v(1));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(1))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]

subplot(5,1,2);
set = find(ProblemSpecs(:,1) == v(2));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(2))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]

subplot(5,1,3);
set = find(ProblemSpecs(:,1) == v(3));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(3))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]

subplot(5,1,4);
set = find(ProblemSpecs(:,1) == v(4));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(4))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]

subplot(5,1,5);
set = find(ProblemSpecs(:,1) == v(5));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(5))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]

%%
figure
low = 0.9;
high = 1.05;
v = unique(ProblemSpecs(:,1));


subplot(5,1,1);
set = find(ProblemSpecs(:,1) == v(1));
hist(Outputs(1,set) ./ Outputs(2,set),200);
title(strcat('Trans / Sum --- when n = ',num2str(v(1))));
xlim([low, high]);
[mean(Outputs(1,set) ./ Outputs(2,set)),
    max(Outputs(1,set) ./ Outputs(2,set))]