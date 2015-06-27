
% each problem requires:
%   P, K, W
numJ = 10:20:100;
numReplications = 1;
maxT = 50;
maxK = 2:10;
numDC = 2:10;
numTrials = length(numJ) * length(maxT) * length(maxK) ...
    * length(numDC) * numReplications;
numVars = 3; % numJobs, Kcst, numDC

Pcollec = cell(numTrials, 1);
Kcollec = cell(numTrials, 1);
Wcollec = cell(numTrials, 1);
DCcollec = cell(numTrials, 2);
ProblemSpecs = zeros(numTrials, numVars);
singlePerm = zeros(numTrials, 2); 
% ^ entry is one if there is a valid single permutation interpretation

%%

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
   W = ones(numJ(jIdx), 1);
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   ProblemSpecs(trial,:) = [numJ(jIdx), maxK(kIdx), numDC(dIdx)];
   
   % Solutions
   
   % Makespan Pre-Processing
   [pMakespan, mappingMakespan] = preProcGeneric(P, K, W, 'makespan');  
   sigmaMakespan = Monaldo(pMakespan, W);
   [DataCentersMakespan, compTimesMakespan] = ...
       mapPreProcBack(sigmaMakespan, mappingMakespan, pMakespan);
   DCcollec{trial, 1} = DataCentersMakespan;
   
   % Weighted Sum Pre-Processing
   [pSum, mappingSum] = preProcGeneric(P, K, W, 'sum');
   sigmaSum = Monaldo(pSum, W);
   [DataCentersSum, compTimesSum] = ...
       mapPreProcBack(sigmaSum, mappingSum, pSum);
   DCcollec{trial, 2} = DataCentersSum;
   
   singlePerm(trial, 1) = determineIfSinglePerm(DataCentersMakespan, P);
   singlePerm(trial, 2) = determineIfSinglePerm(DataCentersSum, P);
   
   trial = trial + 1;
                end
            end
        end
    end
end
