function [fr, MMoverRand] = getErrorRateModMonaldoVsRandom(numTrials,...
    maxTime, numJobs, numDataCenters, K, numPerms)
    
    % inputs
    %
    %   numTrials = a scalar equal to the number of randomly generated
    %   trials to execute in comparing Modified-Monaldo with post
    %   processing to randomly generated permutation with post processing.
    %
    %   maxTime = the maximum amount of time (integer) used in generating a
    %   discrete uniform distribution that populates "P"
    %
    %   numJobs = a scalar equal to the number of jobs used across all
    %   trials.
    %
    %   numDataCenters = a scalar equal to the number of DataCenters for
    %   which jobs need to be scheduled.
    %
    %   K = a vector. K(dc) is the number of servers on DataCenter "dc."
    %
    %   numPerms = the number of random permutations used in comparison
    %   against Modified-Monaldo. If a single one of these permutations
    %   results in a better solution to (CPm | K | sum w_j * c_j) than
    %   Modified-Monaldo then the trial is said to have "failed."
    
    % outputs
    %
    %   fr = the failure "rate" of Modified-Monaldo against random
    %   permutations followed by post processing. Equal to the number of
    %   failures divided by the number of trials.

    W = ones(numJobs, 1);
    P = zeros(numJobs, numDataCenters, numTrials);
    myPerm = zeros(numJobs, numPerms);
    bestPerm = zeros(numTrials, numJobs);

    for t = 1:numTrials
        P(:,:,t) = randi([1,maxTime], numJobs, numDataCenters);
        monaldoSigma(t,:) = ModifiedMonaldo(K, P(:,:,t), W);
        [DataCentersMonaldo{t}, jobCompletionTimesMonaldo{t}] = ...
            GreedilyFollowOrdering(K, P(:,:,t), monaldoSigma(t,:));

        for i = 1:numPerms
            % Test numPerms random permutations. Record the best value
            myPerm = randperm(numJobs);
            [DataCentersRand{t}, output] = ...
                GreedilyFollowOrdering(K, P(:,:,t), myPerm);
            if (i == 1)
                jobCompletionTimesRand{t} = output;
                bestPerm(t,:) = myPerm;
            elseif (sum(output) < sum(jobCompletionTimesRand{t}))
                jobCompletionTimesRand{t} = output;
                bestPerm(t,:) = myPerm;
            end
        end
    end

    objValRand = cellfun(@sum, jobCompletionTimesRand);
    objValMonaldo = cellfun(@sum, jobCompletionTimesMonaldo);

    % save('lastRandP.mat','P');
    fr = sum(objValRand < objValMonaldo) / numTrials;
    MMoverRand = mean(objValMonaldo ./ objValRand);
end