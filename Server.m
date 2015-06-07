classdef Server < handle
   properties
       nextFree % time at which the server becomes free to process another job
       toDo     % list of jobs scheduled jobs (in order processed)
       completionTimes % array of times 
   end
   methods
       % Constructor
       function obj = Server(val)
          if (nargin > 0)
             obj.nextFree = val; 
          else
             obj.nextFree = 0;
          end
       end
   end
end