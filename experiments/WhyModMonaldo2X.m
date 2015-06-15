%% Examine problem instances for which Mod-Monaldo performs ~ 2x as poor as other hueristics.

load('experiments/oneMillion.mat');
cutoff = 1.5;
normIdx = (results(1,:) < cutoff);
badIdx = (results(1,:) >= cutoff);
PNormal = P(:,:,normIdx);
Knormal = K(normIdx,:);
Pbad = P(:,:,badIdx);
Kbad = K(badIdx,:);
numBad = length(Pbad(1,1,:));

%% Overview of Results: Very strange performance distribution.
% The code in this script will hopefully identify reasons why some
% instances of ModifiedMonaldo perform so poorly.

highBetter = 0.99;
lowEven = highBetter;
highEven = 1.01;
lowWorse = highEven;
highWorse = 1.2;
lowBad = highWorse;

figure
subplot(1,4,1);
hist(results(1,results(1,:) <= highBetter), 250);
title('better than even');
subplot(1,4,2);
hist(results(1,((results(1,:) > lowEven) & (results(1,:) <= highEven))), 250);
title('approximately even');
subplot(1,4,3);
hist(results(1,((results(1,:) > lowWorse) & (results(1,:) <= highWorse))), 250);
title('worse than even');
subplot(1,4,4)
hist(results(1,(results(1,:) > lowBad)), 20);
title('bad');

%% Maybe different distributions of K?
KnormalFlat = reshape(Knormal,1,numel(Knormal));
KbadFlat = reshape(Kbad,1,numel(Kbad));

figure
subplot(1,2,1);
hist(KnormalFlat);
title('Normal');
subplot(1,2,2);
hist(KbadFlat);
title('Bad');

% there appears to be a bias towards 1 server on the bad trials.
%   tiny difference in means (mean of Knormal is K_mu = 3, but Matlab's
%   mean function is reported below for completeness).
%   construct 99% confidence interval.

err = norminv(0.995, 0, 1);
badMu = mean(KbadFlat);
badVar = var(KbadFlat);
badMuCI = [ badMu - (var(KbadFlat)/(length(KbadFlat))).^(1/2) * err,...
    badMu + (var(KbadFlat)/(length(KbadFlat))).^(1/2) * err];
display(badMuCI);
normalMu = mean(KnormalFlat);

% appears to be a larger amount of variance in bad trials.
% run F-test on equality of variances.
numManageable = length(KnormalFlat);
testStatisticF = var(KbadFlat) / var(KnormalFlat(1:numManageable));

thresholdF = finv(0.99, length(KbadFlat) - 1, numManageable - 1);
display('Reject the null hypothesis?');
rejectEqualVarianceHypothesis = testStatisticF > thresholdF;
display(rejectEqualVarianceHypothesis);

% lumping everything togther is probably unwise. larger disparities in K
% for given trials may be lost if all K's for "bad" and "normal" trials are
% grouped together.
%

varWithinTrialsBad = var(Kbad, 0, 2);
varWithinTrialsNormal = var(Knormal, 0, 2);
meanVarBad = mean(varWithinTrialsBad);
meanVarNormal = mean(varWithinTrialsNormal);
meanVarBadThenNormal = [meanVarBad, meanVarNormal];
display(meanVarBadThenNormal);

rangeWithinTrialsBad = range(Kbad, 2);
meanRangeBad = mean(rangeWithinTrialsBad);
rangeWithinTrialsNormal = range(Knormal, 2);
meanRangeNormal = mean(rangeWithinTrialsNormal);
meanRangeBadThenNormal = [meanRangeBad, meanRangeNormal];
display(meanRangeBadThenNormal);

%% K alone does not appear to have significant differences. Consider P.
% How will P be measured?
%   SVD.
SB = zeros(numDC, numBad); 
SN = zeros(numDC, numBad);
% each column of SB is the singular values of a Pbad "slice."
% each column of SN is the singular values of a PNormal "slice."
for i = 1:numBad
    SB(:,i) = svd(Pbad(:,:,i),'econ');
    SN(:,i) = svd(PNormal(:,:,i),'econ');
end
% There is no glaring pattern.
%% Consider re-running some of the worst trials.
worstIdx = results(1,:) == max(results(1,:));
W = ones(numJ, 1);
sigma = ModifiedMonaldo(Kbad(1,:),Pbad(:,:,1), W);
[DataCenters, JobCompletionTimes] = ...
    GreedilyFollowOrdering(Kbad(1,:), Pbad(:,:,1), sigma);

%%
for i = 1:numBad
   if (mod(i,100) == 0)
       display(sprintf(strcat(num2str(i/numTrials * 100),'_percent done'))); 
   end
   % W = 10 * rand(numJ, 1);
   W = ones(numJ, 1);
   sigmaMod = ModifiedMonaldo(Kbad(i,:), Pbad(:,:,i), W);
   sigmaAwk = Monaldo(P(:,:,i), W);
   [pPre, mapping] = preProcMinMakespan(Pbad(:,:,i), Kbad(i,:));
   sigmaPre = Monaldo(pPre, W);
   [DataCentersMod, compTimesMod] =...
       GreedilyFollowOrdering(Kbad(i,:), Pbad(:,:,i), sigmaMod);
   [DataCentersPre, compTimesPre] = ...
       mapPreProcBack(sigmaPre, mapping, pPre);
   [DataCentersAwk, compTimesAwk] = ...
       GreedilyFollowOrdering(Kbad(i,:), Pbad(:,:,i), sigmaAwk);
   
   resultsFixed(1,i) = sum(compTimesMod) / sum(compTimesPre);
   resultsFixed(2,i) = sum(compTimesMod) / sum(compTimesAwk);
end

figure
subplot(2,1,1);
plot(resultsFixed(1,:));
title('Mod / Pre');
subplot(2,1,2);
plot(resultsFixed(2,:));
title('Mod / Awk');


