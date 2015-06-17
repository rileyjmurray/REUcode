% each problem requires:
%   P, K, W

%
% This tests the UNWEIGHTED case!
%

numJ = 10:20:100;
numReplications = 10;
maxT = 50;
kMax = 2:2:10;
numDC = 2:10;
numTrials = length(numJ) * length(maxT) * length(kMax) ...
    * length(numDC) * numReplications;
numVars = 3; % numJobs, Kmax, numDC
%%

Outputs = zeros(2,numTrials);
Pcollec = cell(numTrials, 1);
Kcollec = cell(numTrials, 1);
Wcollec = cell(numTrials, 1);
ProblemSpecs = zeros(numTrials, numVars);

trial = 1;
for jIdx = 1:length(numJ)
    for tIdx = 1:length(maxT)
        for kIdx = 1:length(kMax)
            for dIdx = 1:length(numDC)
                for i = 1:numReplications
                    
   % Progress Report
   if (mod(trial, 100) == 0)
   display([jIdx / length(numJ), tIdx / length(maxT), ...
       kIdx / length(kMax), dIdx / length(numDC)]);
   end
                    
   % Generate Problem Data
   K = randi([1,kMax(kIdx)],1, numDC(dIdx));
   P = randi([0,maxT(tIdx)], numJ(jIdx), numDC(dIdx));
   W = ones(numJ(jIdx), 1);
   ProblemSpecs(trial,:) =...
       [numJ(jIdx), kMax(kIdx), numDC(dIdx)];
   
   % Store Problem Data For Later
   Kcollec{trial} = K;
   Pcollec{trial} = P;
   Wcollec{trial} = W;
   
   % Solutions
   sigma = ModifiedMonaldo(K, P, W);
   [DataCentersM, compTimesM] =...
       GreedilyFollowOrdering(K, P, sigma);
   [DataCentersB, compTimesB] =...
       BottleneckDueDates(P, W', K, 'SUM_A', 'LS');
   
   % Record results
   Outputs(1, trial) = W' * compTimesM';
   Outputs(2, trial) = W' * compTimesB';
   
   trial = trial + 1;
                end
            end
        end
    end
end

%%
figure
subplot(2,1,1);
hist(Outputs(1,:) ./ Outputs(2,:), 100);
subplot(2,1,2);
plot(Outputs(1,:) ./ Outputs(2,:));
