%% load Data
load('experiment4.mat');

%% All
mod = (Inputs(:,4) ~= 1);
figure

subplot(4,1,1);
scatter(Inputs(mod,1),Outputs(mod,2));
title('Performance Ratio (MM / Rand) for Various Inputs (Mod-Monaldo with post processing)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
scatter(Inputs(mod,2),Outputs(mod,2));
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
scatter(Inputs(mod,3),Outputs(mod,2));
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
scatter(Inputs(mod,4),Outputs(mod,2));
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));

%% Standard Monaldo
std = (Inputs(:,4) == 1);

figure

subplot(4,1,1);
scatter(Inputs(std,1),Outputs(std,2));
title('Performance Ratio (Monaldo / Rand) for Various Inputs (Std-Monaldo)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
scatter(Inputs(std,2),Outputs(std,2));
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
scatter(Inputs(std,3),Outputs(std,2));
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
scatter(Inputs(std,4),Outputs(std,2));
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));
