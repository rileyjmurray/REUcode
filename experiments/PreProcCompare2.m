%%
load('PreProcData.mat');
sameSoln = 1;
threshold = 0.005;
makespanWorse = (results(:) > sameSoln+threshold);
sumWorse = (results(:) < sameSoln-threshold);

%P1 = P(:,:,makespanWorse);
%K1 = K(makespanWorse,:);
%P2 = P(:,:,sumWorse);
%K2 = K(sumWorse,:);

%%
figure
subplot(1,3,1);
h = histogram(results(makespanWorse), 100);
h.FaceColor = 'r';
title('makespan does worse');

subplot(1,3,2);
hold on
results2 = ones(size(results(sumWorse))) ./ results(sumWorse);
histogram(results2, 100);
h = histogram(results(makespanWorse), 100);
h.FaceColor = 'r';
title('both');

subplot(1,3,3);
histogram(results2, 100);
title('sum does worse');