%% load Data
load('experiment1.mat');

%% All
figure

subplot(4,1,1);
stem(Inputs(:,1),Outputs(:,1));
title('Failure Rate for Various Inputs (Failure IFF random better than hueristic)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
stem(Inputs(:,2),Outputs(:,1));
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
stem(Inputs(:,3),Outputs(:,1));
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
stem(Inputs(:,4),Outputs(:,1));
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));

%% Standard Monaldo
std = (Inputs(:,4) == 1);

figure

subplot(4,1,1);
stem(Inputs(std,1),Outputs(std,1));
title('Failure Rate for Standard Monaldo (Failure IFF random better than hueristic)');
xlabel('maxTime');
set(gca, 'XTick', unique(Inputs(:,1)));

subplot(4,1,2);
stem(Inputs(std,2),Outputs(std,1));
xlabel('numJobs');
set(gca, 'XTick', unique(Inputs(:,2)));

subplot(4,1,3);
stem(Inputs(std,3),Outputs(std,1));
xlabel('numDataCenters');
set(gca, 'XTick', unique(Inputs(:,3)));

subplot(4,1,4);
stem(Inputs(std,4),Outputs(std,1));
xlabel('numServers per DataCenter');
set(gca, 'XTick', unique(Inputs(:,4)));
