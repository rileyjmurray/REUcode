
% each problem requires:
%   P, K, W
numJ = 20:20:100;
numReplications = 10;
maxT = 50;
maxK = 5:10;
numDC = 2:10;
maxWt = 50;
numTrials = length(numJ) * length(maxT) * length(maxK) ...
    * length(numDC) * numReplications;
numVars = 3; % numJobs, Kcst, numDC
%%

Outputs = zeros(3,numTrials);
Pcollec = cell(numTrials, 1);
Kcollec = cell(numTrials, 1);
Wcollec = cell(numTrials, 1);
ProblemSpecs = zeros(numTrials, numVars);

trial = 1;
for jIdx = 1:length(numJ)
    for tIdx = 1:length(maxT)
        for kIdx = 1:length(maxK)
            for dIdx = 1:length(numDC)
                for i = 1:numReplications
                    
   % Progress Report
   if (mod(trial, 100) == 0 || trial == numTrials)
   display([jIdx / length(numJ), tIdx / length(maxT), ...
       kIdx / length(maxK), dIdx / length(numDC)]);
   end
                    
   % Generate Problem Data
   K = randi([1, maxK(kIdx)], 1, numDC(dIdx));
   P = randi([0,maxT(tIdx)], numJ(jIdx), numDC(dIdx));
   n = size(P,1);
   W = maxWt * rand(numJ(jIdx), 1);
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   ProblemSpecs(trial,:) = [numJ(jIdx), maxK(kIdx), numDC(dIdx)];
   
   % Modified Monaldo
   sigmaMod = ModifiedMonaldo(K, P, W);
   [DataCentersMod, compTimesMod] =...
       GreedilyFollowOrdering(K, P, sigmaMod);
 
   % Makespan Pre-Processing
   [pMakespan, mappingMakespan] = preProcGeneric(P, K, W, 'makespan');  
   sigmaMakespan = Monaldo(pMakespan, W);
   [DataCentersMakespan, compTimesMakespan] = ...
       mapPreProcBack(sigmaMakespan, mappingMakespan, pMakespan);
   
   % Weighted Sum Pre-Processing
   [pSum, mappingSum] = preProcGeneric(P, K, W, 'sum');
   sigmaSum = Monaldo(pSum, W);
   [DataCentersSum, compTimesSum] = ...
       mapPreProcBack(sigmaSum, mappingSum, pSum);
   
   % Record results
   Outputs(1, trial) = W' * compTimesMod';
   Outputs(2, trial) = W' * compTimesMakespan';
   Outputs(3, trial) = W' * compTimesSum';
   
   trial = trial + 1;
                end
            end
        end
    end
end
