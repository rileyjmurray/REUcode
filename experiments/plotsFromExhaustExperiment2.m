%% load Data
load('exhaust_experiment2.mat');

%% All

% plot Number of DataCenters (X) and Number of Servers / DataCenter (Y)
%   against FailureRate
figure1 = figure;
% Create axes
axes1 = axes('Parent',figure1,'XTick',[2 3 4 5]);
view(axes1,[-8.5 10]);
grid(axes1,'on');
hold(axes1,'on');
% Create stem3
stem3(Inputs(:,3),Inputs(:,4),Outputs(:,1));
xlabel('Number of DataCenters');
ylabel('Number of Servers / DataCenter');
zlabel('FailureRate');

%% plot Number of DataCenters (X) and Number of Servers / DataCenter (Y)
%   against Performance Ratio (Modified-Monaldo / AllPerms)
figure1 = figure;
axes1 = axes('Parent',figure1,'XTick',[2 3 4 5]);
zlim(axes1,[1 1.05]);
view(axes1,[-13.5 10]);
grid(axes1,'on');
hold(axes1,'on');
stem3(Inputs(:,3),Inputs(:,4),Outputs(:,2));
% Create xlabel
xlabel('Number of DataCenters');
% Create ylabel
ylabel('Number of Servers / DataCenter');
% Create zlabel
zlabel('Performance Ratio (Modified-Monaldo / AllPerms)');

