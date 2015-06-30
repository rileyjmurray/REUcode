
ObjectiveOutputs = zeros(2,numTrials);
lowerBound = zeros(1,numTrials);
TimingOutputs = zeros(3,numTrials);

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

   % Parallel-Aware Monaldo
   tic;
   sigmaMon = ParallelAwareMonaldo(K, P, W);
   [~, compTimesMon] = GreedilyFollowOrdering(K, P, sigmaMon);
   monT = toc;
   
   % 3-Approximation Linear Program - minimal constraints
   tic;
   inst = javaObject('COmKInstance', P, K, W);
   lp = javaObject('ThreeApproxLPSimplex',inst,'none');
   lp.solve();
   TlpMin = toc;

   % Record results
   ObjectiveOutputs(1, trial) = W' * compTimesMon';
   ObjectiveOutputs(2, trial) = inst.getObjVal();
   lowerBound(trial) = lp.getLPObjective();
   TimingOutputs(1, trial) = monT;
   TimingOutputs(2, trial) = TlpMin;
   
   trial = trial + 1;
                end
            end
        end
    end
end