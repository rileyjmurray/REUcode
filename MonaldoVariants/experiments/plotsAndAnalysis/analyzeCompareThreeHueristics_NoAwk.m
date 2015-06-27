
% from "compareThreeHueristics_randK_randW.m"
%  Outputs(1, trial) = W' * compTimesMod';
%  Outputs(2, trial) = W' * compTimesMakespan';
%  Outputs(3, trial) = W' * compTimesSum';

figure

subplot(3,1,1);
hist(Outputs(1,:) ./ Outputs(2,:),500);
title('Mod / Makespan');
mean(Outputs(1,:) ./ Outputs(2,:))

subplot(3,1,2);
hist(Outputs(1,:) ./ Outputs(3,:),500);
title('Mod / Sum');
mean(Outputs(1,:) ./ Outputs(3,:))

subplot(3,1,3);
hist(Outputs(2,:) ./ Outputs(3,:),500);
title('Makespan / Sum');
mean(Outputs(2,:) ./ Outputs(3,:))
