'''
Created on Jan 17, 2016

@author: RJMurray
'''
import unittest
import cc_environment as cc

class testCCenvironment(unittest.TestCase):

    def test_instantiate_without_error(self):
        testClustSpecs = [[1],[2],[1.5,1]]
        testController  = cc.Controller(testClustSpecs)
        self.assertTrue(testController.numClusters == 3)
        self.assertTrue(len(testController.memberClusters[0].machines) == 1)
        self.assertTrue(len(testController.memberClusters[1].machines) == 1)
        self.assertTrue(len(testController.memberClusters[2].machines) == 2)
        self.assertTrue(testController.memberClusters[0].machines[0].speed == 1)
        self.assertTrue(testController.memberClusters[1].machines[0].speed == 2)
        self.assertTrue(testController.memberClusters[2].machines[1].speed == 1)
        pass
    
    def test_update_machine_loads(self):
        testClustSpecs = [[1],[2],[1.5,1]]
        testController  = cc.Controller(testClustSpecs)
        
        testController.memberClusters[0].schedJobOnEarliestCompMachines(0,[2.0, 3.0])
        self.assertTrue(testController.memberClusters[0].machines[0].nextFree == 5)
        
        testController.memberClusters[1].schedJobOnEarliestCompMachines(0,[4.0])
        self.assertTrue(testController.memberClusters[1].machines[0].nextFree == 2.0)
        
        testController.memberClusters[2].schedJobOnEarliestCompMachines(0,[1.0])
        self.assertTrue(testController.memberClusters[2].machines[0].nextFree == 1.0/1.5)
        testController.memberClusters[2].schedJobOnEarliestCompMachines(0,[15.0])
        self.assertTrue(testController.memberClusters[2].machines[0].nextFree == (1.0/1.5 + 15/1.5))
        self.assertTrue(testController.memberClusters[2].machines[1].nextFree == 0)
        

suite = unittest.TestLoader().loadTestsFromTestCase(testCCenvironment)
unittest.TextTestRunner(verbosity=1).run(suite)