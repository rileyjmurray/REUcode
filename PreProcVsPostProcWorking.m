
% each problem requires:
%   P, K, W
numJ = 10;
numTrials = 1000000;
maxT = 50;
maxK = 5;
numDC = 5;

results = zeros(2,numTrials);
%P = zeros(numJ, numDC, numTrials);
%K = zeros(numTrials, numDC);

for i = 1:numTrials
   if (mod(i,100) == 0)
       display(sprintf(strcat(num2str(i/numTrials * 100),'_percent done'))); 
   end
   %P(:,:,i) = randi([0,maxT], numJ, numDC);
   %K(i,:) = randi([1,maxK], 1, numDC);
   % W = 10 * rand(numJ, 1);
   W = ones(numJ, 1);
   sigmaMod = ModifiedMonaldo(K(i,:), P(:,:,i), W);
   sigmaAwk = Monaldo(P(:,:,i), W);
   [pPre, mapping] = preProcMinMakespan(P(:,:,i), K(i,:));
   sigmaPre = Monaldo(pPre, W);
   [DataCentersMod, compTimesMod] =...
       GreedilyFollowOrdering(K(i,:), P(:,:,i), sigmaMod);
   [DataCentersPre, compTimesPre] = ...
       mapPreProcBack(sigmaPre, mapping, pPre);
   [DataCentersAwk, compTimesAwk] = ...
       GreedilyFollowOrdering(K(i,:), P(:,:,i), sigmaAwk);
   
   results(1,i) = sum(compTimesMod) / sum(compTimesPre);
   results(2,i) = sum(compTimesMod) / sum(compTimesAwk);
end

%%
figure
subplot(2,1,1);
plot(results(1,:));
title('Mod / Pre');
subplot(2,1,2);
plot(results(2,:));
title('Mod / Awk');