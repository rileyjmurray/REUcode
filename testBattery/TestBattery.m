numJ = 10;
numTrials = 50;
maxT = 20;
numDC = 2:5;
kScalar = 1:5;
numPerms = 50;

% R is "results" matrix (in practice do analysis on "Inputs").
R = zeros(length(numJ), length(maxT), length(numDC), length(kScalar));
Inputs = zeros(length(numJ) * length(maxT) * length(numDC) *...
    length(kScalar),4);

% Outputs(row,1) is the FailureRate of Inputs(row,:)
% Outputs(row,2) is the Performance Ratio of Inputs(row,:)
Outputs = zeros(size(Inputs,1),2);

row = 1;
for i = 1:length(numJ)
    for j = 1:length(maxT)
        for k = 1:length(numDC)
            for l = 1:length(kScalar)
                progress = [i / length(numJ), j / length(maxT),...
                    k / length(numDC), l / length(kScalar)];
                display(progress);
                [R(i,j,k,l), perfRat] = getErrorRateModMonaldoVsRandom(...
                    numTrials,...
                    maxT(j),...
                    numJ(i),...
                    numDC(k),...
                    kScalar(l) * ones(1,numDC(k)),...
                    numPerms);
                Inputs(row,:) = [maxT(j), numJ(i), numDC(k),kScalar(l)];
                Outputs(row,1) = R(i,j,k,l); % FailureRate
                Outputs(row,2) = perfRat; % mean(ObjVal_Rand / ObjVal_MM)
                row = row + 1;
            end
        end
    end
end
