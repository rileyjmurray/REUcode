
% each problem requires:
%   P, K, W
numJ = 10:20:100;
numReplications = 50;
maxT = 50;
Kcst = 2:10;
numDC = 2:10;
numTrials = length(numJ) * length(maxT) * length(Kcst) ...
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
        for kIdx = 1:length(Kcst)
            for dIdx = 1:length(numDC)
                for i = 1:numReplications
                    
   % Progress Report
   if (mod(trial, 100) == 0 || trial == numTrials)
   display([jIdx / length(numJ), tIdx / length(maxT), ...
       kIdx / length(Kcst), dIdx / length(numDC)]);
   end
                    
   % Generate Problem Data
   K = Kcst(kIdx) * ones(1, numDC(dIdx));
   P = randi([0,maxT(tIdx)], numJ(jIdx), numDC(dIdx));
   W = ones(numJ(jIdx), 1);
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   ProblemSpecs(trial,:) = [numJ(jIdx), Kcst(kIdx), numDC(dIdx)];
   
   % Solutions
   sigmaMod = ModifiedMonaldo(K, P, W);
   sigmaAwk = Monaldo(P, W);
   [pPre, mapping] = preProcMinMakespan(P, K);
   sigmaPre = Monaldo(pPre, W);
   [DataCentersMod, compTimesMod] =...
       GreedilyFollowOrdering(K, P, sigmaMod);
   [DataCentersPre, compTimesPre] = ...
       mapPreProcBack(sigmaPre, mapping, pPre);
   [DataCentersAwk, compTimesAwk] = ...
       GreedilyFollowOrdering(K, P, sigmaAwk);
   
   % Record results
   Outputs(1, trial) = sum(compTimesMod);
   Outputs(2, trial) = sum(compTimesPre);
   Outputs(3, trial) = sum(compTimesAwk);
   
   trial = trial + 1;
                end
            end
        end
    end
end
