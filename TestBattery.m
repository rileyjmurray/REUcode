numJ = 10:20:100;
numTrials = 50;
maxT = 50;
numDC = 1:5;
kScalar = 1:5;
numPerms = 10;

% R is "results" matrix (in practice do analysis on "Inputs").
R = zeros(length(numJ), length(maxT), length(numDC), length(kScalar));
Inputs = zeros(length(numJ) * length(maxT) * length(numDC) *...
    length(kScalar),4);

% FailureRate(row) is the FailureRate of Inputs(row,:)
FailureRate = zeros(size(Inputs,1));

row = 1;
for i = 1:length(numJ)
    for j = 1:length(maxT)
        for k = 1:length(numDC)
            for l = 1:length(kScalar)
                progress = [i / length(numJ), j / length(maxT),...
                    k / length(numDC), l / length(kScalar)];
                display(progress);
                R(i,j,k,l) = getErrorRateModMonaldoVsRandom(...
                    numTrials,...
                    maxT(j),...
                    numJ(i),...
                    numDC(k),...
                    kScalar(l) * ones(1,numDC(k)),...
                    numPerms);
                Inputs(row,:) = [maxT(j), numJ(i), numDC(k),kScalar(l)];
                FailureRate(row) = R(i,j,k,l);
                row = row + 1;
            end
        end
    end
end
