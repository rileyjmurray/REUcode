% Use this script if you find a bug in any of the following: 
%   Modified-Monaldo
%   GreedilyFollowOrdering
%   getGlobalErrorRateModMonaldo
%   getErrorRateModMonaldoVsRandom

clear;
load('experiment1.mat');
clear FailureRate;
clear R;
clear Inputs;
TestBatteryParamsPriorDelcared;
save('experiment1.mat', FailureRate, Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, R);

clear;
load('experiment2.mat');
clear FailureRate;
clear R;
clear Inputs;
TestBatteryParamsPriorDelcared;
save('experiment2.mat', FailureRate, Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, R);

clear;
load('experiment2.mat');
clear FailureRate;
clear R;
clear Inputs;
TestBatteryParamsPriorDelcared;
save('experiment2.mat', FailureRate, Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, R);

clear;
load('experiment3.mat');
clear FailureRate;
clear R;
clear Inputs;
TestBatteryParamsPriorDelcared;
save('experiment3.mat', FailureRate, Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, R);

clear;
load('experiment4.mat');
clear Outputs;
clear R;
clear Inputs;
TestBatteryParamsPriorDelcared;
save('experiment4.mat', Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, Outputs, R);

clear;
load('exhaust_experiment1.mat');
clear Outputs;
clear R;
clear Inputs;
TestBatteryExhaustiveParamsPriorDelcared;
save('exhaust_experiment1.mat', Inputs, kScalar, maxT, numDC,...
    numJ, numPerms, numTrials, Outputs, R);
