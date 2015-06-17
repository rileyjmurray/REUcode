for i = 1:numTrials
   if (mod(i,100) == 0) % percent done for large number of trials
      display(sprintf(strcat(num2str(i/numTrials * 100),'_percent done'))); 
   end
   
   P(:,:,i) = randi([0,maxT], numJ, numDC);
   K(i,:) = randi([1,maxK], 1, numDC);
   W = ones(numJ, 1); % unweighted
   
   [pPre1, mapping1] = preProcGeneric(P(:,:,i), K(i,:), W, 'makespan');
   [pPre2, mapping2] = preProcGeneric(P(:,:,i), K(i,:), W, 'sum');
   
   sigmaPreMakespan = Monaldo(pPre1, W);
   sigmaPreSum = Monaldo(pPre2, W);
   
   [DataCentersPreMakespan, compTimesPreMakespan] = ...
        mapPreProcBack(sigmaPreMakespan, mapping1, pPre1);
    
   [DataCentersPreSum, compTimesPreSum] = ...
        mapPreProcBack(sigmaPreSum, mapping2, pPre2);
   
   results(i) = (W' * compTimesPreMakespan') / (W' * compTimesPreSum');
end
