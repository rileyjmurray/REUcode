'''
Created on Jan 17, 2016

@author: RJMurray
'''
# need: MUSSQ implementation, cluster definition, machine definition

import numpy as np
import random

class Controller():
    def __init__(self, clusterSpecs):
        # clusterSpecs is a list "numClusters" lists
        self.numClusters = len(clusterSpecs)
        self.memberClusters = []
        for i in range(self.numClusters):
            self.memberClusters.append(Cluster(i,clusterSpecs[i]))

class Cluster():
    
    def __init__(self, inId, inMachineSpeeds):
        inMachineSpeeds.sort(reverse=True)
        self.numMachines = len(inMachineSpeeds)
        self.machines = []
        self.id = inId
        for i in range(self.numMachines):
            self.machines.append(Machine(i, inMachineSpeeds[i]))

    def schedJobOnEarliestCompMachines(self, job, procReqs):
        # right now, "job" isn't used (likely will be later)
        # schedule one task at a time
        if (not all(procReqs[i] >= procReqs[i+1] for i in xrange(len(procReqs)-1))):
            procReqs.sort(reverse=True)
        for pr in procReqs:
            # identify the machine on which this task will finish first
            bestMach = self.machines[0];
            bestCompTime = np.inf
            for i in range(self.numMachines): 
                compTime = self.machines[i].nextFree + (pr / self.machines[i].speed)
                if (compTime <= bestCompTime):
                    bestCompTime = compTime
                    bestMach = self.machines[i]
            # identified best machine; schedule this task!
            bestMach.nextFree = bestCompTime
        
class Machine():
    
    def __init__(self, inId, inSpeed):
        self.speed = inSpeed
        self.id = inId
        self.nextFree = 0.0
    

def mussq(P,w):
    # Inputs:
    # P = 2D array matrix of processing times, 
    #   one job per row (i.e. P[j,:] is data for job "j")
    #   one cluster per column (sub-jobs are 1-to-1 with clusters)
    # w = an array of positive floats (w[j] is weight for job "j")
    # Outputs:
    # sigma = permutation of the [number-of-rows-of-P] jobs
    
    # initialize
    n = P.shape[0] # number of jobs
    J = set(range(n)) # set of as-yet-unscheduled jobs
    sigma = np.zeros([1,n], dtype=np.int)
    L = np.sum(P, axis=0)
    
    # bulk of routine
    for k in reversed(range(n)):
        bottleneck = np.argmax(L)
        bestjob = random.sample(J)
        smallestRatio = np.inf
        for j in J:
            if (P[j,bottleneck] > 0):
                ratio = w[j] / P[j,bottleneck]
                if (ratio <= smallestRatio):
                    bestjob = j
                    smallestRatio = ratio
        sigma[k] = bestjob
        theta = w[sigma[k]] / P[sigma[k],bottleneck]
        for j in J:
            w[j] = w[j] - theta * P[sigma[k],bottleneck]
        L = L - P[sigma[k],:]
        J.remove(sigma[k])
    
    return sigma
                
        
    