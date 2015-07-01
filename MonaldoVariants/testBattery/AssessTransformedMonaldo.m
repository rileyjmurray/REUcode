
% each problem requires:
%   P, K, W
numJ = 1000;
numReplications = 5;
invT = 50;
minK = 3:10;
noiseK = 3;
numDC = 2:10;
noiseWt = 1;
avgWt = 3.5;
numTrials = length(numJ) * length(invT) * length(minK) ...
    * length(numDC) * numReplications;
numVars = 3; % numJobs, Kcst, numDC
%%

Outputs = zeros(2,numTrials);
Pcollec = cell(numTrials, 1);
Kcollec = cell(numTrials, 1);
Wcollec = cell(numTrials, 1);
ProblemSpecs = zeros(numTrials, numVars);

trial = 1;
for jIdx = 1:length(numJ)
    for tIdx = 1:length(invT)
        for kIdx = 1:length(minK)
            for dIdx = 1:length(numDC)
                for i = 1:numReplications
                    
   % Progress Report
   if (mod(trial, 100) == 0 || trial == numTrials)
   display([jIdx / length(numJ), tIdx / length(invT), ...
       kIdx / length(minK), dIdx / length(numDC)]);
   end
                    
   % Generate Problem Data
   K = randi([minK(kIdx), minK(kIdx) + noiseK], 1, numDC(dIdx));
   P = randi([1,invT(tIdx)], numJ(jIdx), numDC(dIdx));
   P = ones(size(P)) ./ P; 
   n = size(P,1);
   W = avgWt + noiseWt * rand(numJ(jIdx), 1);
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   ProblemSpecs(trial,:) = [numJ(jIdx), minK(kIdx), numDC(dIdx)];
   
   % Transformed Monaldo
   Pmod = TransformCOmKToPDm(P, K);
   sigmaTrans = Monaldo(Pmod, W);
   [~, compTimesTrans] = GreedilyFollowOrdering(K, P, sigmaTrans);

   % Weighted Sum Pre-Processing
   [pSum, mappingSum] = preProcGeneric(P, K, W, 'sum');
   sigmaSum = Monaldo(pSum, W);
   [~, compTimesSum] = mapPreProcBack(sigmaSum, mappingSum, pSum);
   
   % Record results
   Outputs(1, trial) = W' * compTimesTrans';
   Outputs(2, trial) = W' * compTimesSum';
   
   
   trial = trial + 1;
                end
            end
        end
    end
end
