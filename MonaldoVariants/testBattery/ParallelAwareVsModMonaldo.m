

numTrials = 500;

Outputs2 = zeros(2, numTrials);
P2collec = cell(1, numTrials);
W2collec = cell(1, numTrials);
K2collec = cell(1, numTrials);

for i = 1:numTrials
    
    n = size(Pcollec{i},1);
    m = size(Pcollec{i},2);
    P2collec{i} = exprnd(25,n,m);
    W2collec{i} = 10  + (5 * rand(1)) * ones(n,1);
    K2collec{i} = (4 * ones(1,m) + randi([1,3],1,m));
    
    sigma = ParallelAwareMonaldo(K2collec{i}, P2collec{i}, W2collec{i});
    [~, compTimes] = GreedilyFollowOrdering(Kcollec{i}, P2collec{i}, sigma);
    
    sigma = ModifiedMonaldo(K2collec{i}, P2collec{i}, W2collec{i});
    [~, compTimesMod] = GreedilyFollowOrdering(Kcollec{i}, P2collec{i}, sigma);
    
    Outputs2(1, i) = W2collec{i}' * compTimes';
    Outputs2(2, i) = W2collec{i}' * compTimesMod';
    
end

%%

%  Outputs2(1, i) = parallel aware;
%  Outputs2(2, i) = modified monaldo;

figure
hist(Outputs2(1,:) ./ Outputs2(2,:),numTrials / 3);
title('ParallelAware / Mod');
mean(Outputs2(1,:) ./ Outputs2(2,:))

