
Outputs = zeros(3,numTrials);

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
   K = Kcollec{trial};
   P = Pcollec{trial};
   n = size(P,1);
   W = Wcollec{trial};
   
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
