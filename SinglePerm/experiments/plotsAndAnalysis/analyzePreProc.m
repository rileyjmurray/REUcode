%%
load('PreProcData.mat');
sameSoln = 1;
threshold = 0.005;
% entries of results matrix come in form makespan/sum
% results where makespan does worse
makespanWorse = (results(:) > sameSoln+threshold);

% results where sum does worse
sumWorse = (results(:) < sameSoln-threshold);

%% COMPARING HISTOGRAMS
% red = makespan does worse
% blue = sum does worse

figure
subplot(1,3,1);
h = histogram(results(makespanWorse), 75);
h.FaceColor = 'r';
title('makespan does worse');

subplot(1,3,2);
hold on

% take reciprocal of results where sum does worse
results2 = ones(size(results(sumWorse))) ./ results(sumWorse);
histogram(results2, 75);
h = histogram(results(makespanWorse), 75);
h.FaceColor = 'r';
title('both');

subplot(1,3,3);
histogram(results2, 75);
title('sum does worse');