%%
load('experiments/c3h1.mat');

%%
figure

subplot(3,1,1);
hist(Outputs(1,:) ./ Outputs(2,:));
title('Mod / Pre');
mean(Outputs(1,:) ./ Outputs(2,:))

subplot(3,1,2);
hist(Outputs(1,:) ./ Outputs(3,:));
title('Mod / Awk');
mean(Outputs(1,:) ./ Outputs(3,:))

subplot(3,1,3);
hist(Outputs(2,:) ./ Outputs(3,:));
title('Pre / Awk');
mean(Outputs(2,:) ./ Outputs(3,:))

%%
[out1Sort, ~] = sort(Outputs(1,:));
plot(out1Sort(20000:30000));
