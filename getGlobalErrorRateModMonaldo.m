function [fr, MMoverRand] = getGlobalErrorRateModMonaldo(numTrials,...
    maxTime, numJobs, numDataCenters, K)
    
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
    %   trials. numJobs must be less than 9.
    %
    %   numDataCenters = a scalar equal to the number of DataCenters for
    %   which jobs need to be scheduled.
    %
    %   K = a vector. K(dc) is the number of servers on DataCenter "dc."
    
    % outputs
    %
    %   fr = the failure "rate" of Modified-Monaldo against random
    %   permutations followed by post processing. Equal to the number of
    %   failures divided by the number of trials.
    %
    %   MMoverRand = the objective function value of Modified-Monaldo
    %   divided by the objective function value of the best of all
    %   permutations for the given set of jobs.
    
    if (numJobs >= 9)
       sprintf('ATTENTION!: The number of jobs is too high.');
       sprintf('    The script will run for several hours, or days.');
       sprintf('    Please cancel execution with ''control + c''');
       sprintf('    Run again with no more than 8 jobs.'); 
    end
    
    W = ones(numJobs, 1);
    P = zeros(numJobs, numDataCenters, numTrials);
    bestPerm = zeros(numTrials, numJobs);
    allPerms = perms(1:numJobs);

    for t = 1:numTrials
        P(:,:,t) = randi([1,maxTime], numJobs, numDataCenters);
        monaldoSigma(t,:) = ModifiedMonaldo(K, P(:,:,t), W);
        [DataCentersMonaldo{t}, jobCompletionTimesMonaldo{t}] = ...
            GreedilyFollowOrdering(K, P(:,:,t), monaldoSigma(t,:));

        for i = 1:length(allPerms)
            % Test numPerms random permutations. Record the best value
            myPerm = allPerms(i,:);
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