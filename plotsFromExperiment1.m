%% load Data
load('experiment1.mat');

%% All
figure

subplot(4,1,1);
stem(Inputs(:,1),FailureRate);
title('Failure Rate for Various Inputs (Failure IFF random better than hueristic)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
stem(Inputs(:,2),FailureRate);
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
stem(Inputs(:,3),FailureRate);
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
stem(Inputs(:,4),FailureRate);
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));

%% Standard Monaldo
std = (Inputs(:,4) == 1);

figure

subplot(4,1,1);
stem(Inputs(std,1),FailureRate(std));
title('Failure Rate for Standard Monaldo (Failure IFF random better than hueristic)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
stem(Inputs(std,2),FailureRate(std));
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
stem(Inputs(std,3),FailureRate(std));
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
stem(Inputs(std,4),FailureRate(std));
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));
