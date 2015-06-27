%%

% mapping completion times schedules jobs-tasks of zero duration, which
%   is dis-advantageous when the zero-duration jobs are not at
%   the beginning

figure;

subplot(2,1,1);
hist(singlePerm(:,1));
title('Makespan');

subplot(2,1,2);
hist(singlePerm(:,2));
title('Sum');

