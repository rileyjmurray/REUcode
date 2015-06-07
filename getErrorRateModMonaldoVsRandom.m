function fr = getErrorRateModMonaldoVsRandom(numTrials, maxTime,...
    numJobs, numDataCenters, K, numPerms)
    
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

    save('lastRandP.mat','P');
    fr = sum(objValRand < objValMonaldo) / numTrials;
end