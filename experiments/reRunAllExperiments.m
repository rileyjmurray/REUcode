% Use this script if you find a bug in any of the following: 
%   Modified-Monaldo
%   GreedilyFollowOrdering
%   getGlobalErrorRateModMonaldo
%   getErrorRateModMonaldoVsRandom

clear;
load('experiment1.mat');
clear Outputs;
clear R;
clear Inputs;
msg = 'Running experiement 1';
display(msg);
run TestBatteryParamsPriorDeclared;
save('experiment1.mat', 'Outputs', 'Inputs', 'kScalar', 'maxT', 'numDC',...
    'numJ', 'numPerms', 'numTrials', 'R');

clear;
load('experiment2.mat');
clear Outputs;
clear R;
clear Inputs;
msg = 'Running experiement 2';
display(msg);
run TestBatteryParamsPriorDeclared;
save('experiment2.mat', 'Outputs', 'Inputs', 'kScalar', 'maxT', 'numDC',...
    'numJ', 'numPerms', 'numTrials', 'R');

clear;
load('experiment3.mat');
clear Outputs;
clear R;
clear Inputs;
msg = 'Running experiement 3';
display(msg);
run TestBatteryParamsPriorDeclared;
save('experiment3.mat', 'Outputs', 'Inputs', 'kScalar', 'maxT', 'numDC',...
    'numJ', 'numPerms', 'numTrials', 'R');

clear;
load('experiment4.mat');
clear Outputs;
clear R;
clear Inputs;
msg = 'Running experiement 4';
display(msg);
run TestBatteryParamsPriorDeclared;
save('experiment4.mat', 'Outputs', 'Inputs', 'kScalar', 'maxT', 'numDC',...
    'numJ', 'numPerms', 'numTrials', 'R');

clear;
load('exhaust_experiment1.mat');
clear Outputs;
clear R;
clear Inputs;
msg = 'Running exhaustive experiement 1';
display(msg);
run TestBatteryExhaustiveParamsPriorDeclared;
save('exhaust_experiment1.mat', 'Inputs', 'kScalar', 'maxT', 'numDC',...
    'numJ', 'numTrials', 'Outputs', 'R');
