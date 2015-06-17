figure

subplot(3,1,1);
hist(Outputs(1,:) ./ Outputs(2,:),500);
title('Mod / Pre');
mean(Outputs(1,:) ./ Outputs(2,:))

subplot(3,1,2);
hist(Outputs(1,:) ./ Outputs(3,:),500);
title('Mod / Awk');
mean(Outputs(1,:) ./ Outputs(3,:))

subplot(3,1,3);
hist(Outputs(2,:) ./ Outputs(3,:),500);
title('Pre / Awk');
mean(Outputs(2,:) ./ Outputs(3,:))
