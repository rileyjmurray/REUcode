
% each problem requires:
%   P, K, W
numJ = 10:20:100;
numReplications = 10;
maxT = 10:10:50;
maxK = 5:10;
numDC = 1;
maxWt = 10:10:50;
numTrials = length(numJ) * length(maxT) * length(maxK) ...
    * length(numDC) * length(maxWt) * numReplications;
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
                for wIdx = 1:length(maxWt)
                    for i = 1:numReplications
                    
   % Progress Report
   if (mod(trial, 100) == 0 || trial == numTrials)
   display([jIdx / length(numJ), tIdx / length(maxT), ...
       kIdx / length(maxK), dIdx / length(numDC)]);
   end
                    
   % Generate Problem Data
   K = randi([1, maxK(kIdx)], 1, numDC(dIdx));
   P = randi([1,maxT(tIdx)], numJ(jIdx), numDC(dIdx));
   W = maxWt(wIdx) * rand(numJ(jIdx), 1);
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   ProblemSpecs(trial,:) = [numJ(jIdx), maxK(kIdx), numDC(dIdx)];
   
   % Solutions
   [pMkspn, mappingMkspn] = preProcGeneric(P, K, W, 'makespan');
   sigmaMkspn = Monaldo(pMkspn, W);
   [DataCentersMkspn, compTimesMkspn] = ...
       mapPreProcBack(sigmaMkspn, mappingMkspn, pMkspn);
   
   [pSum, mappingSum] = preProcGeneric(P, K, W, 'sum');
   sigmaSum = Monaldo(pSum, W);
   [DataCentersSum, compTimesSum] = ...
       mapPreProcBack(sigmaSum, mappingSum, pSum);
   
   [~, jobsByWLPT] = sort(W ./ P, 'descend');
   [DataCentersWLPT, compTimesWLPT] = GreedilyFollowOrdering(...
       K, P, jobsByWLPT);
   
   % Record results
   Outputs(1, trial) = W' * compTimesMkspn';
   Outputs(2, trial) = W' * compTimesSum';
   Outputs(3, trial) = W' * compTimesWLPT';
   
   trial = trial + 1;
                    end
                end
            end
        end
    end
end
