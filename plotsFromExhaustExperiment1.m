%% load Data
load('exhaust_experiment1.mat');

%% All

figure

% plot Number of DataCenters (X) and Number of Servers / DataCenter (Y)
%   against FailureRate
subplot(1,2,1);
stem3(Inputs(:,3),Inputs(:,4),Outputs(:,1));
xlabel('Number of DataCenters')
ylabel('Number of Servers / DataCenter');
zlabel('FailureRate');

% plot Number of DataCenters (X) and Number of Servers / DataCenter (Y)
%   against Performance Ratio (Modified-Monaldo / AllPerms)
subplot(1,2,2);
stem3(Inputs(:,3),Inputs(:,4),Outputs(:,2));
zlim([0.9,1.1]);
xlabel('Number of DataCenters')
ylabel('Number of Servers / DataCenter');
zlabel('Performance Ratio (Modified-Monaldo / AllPerms)');


