
import gurobi.*;
import java.util.Arrays;

public class RunThreeApprox {

	public double v;
	public int[] s;

	public static void main(String[] args) throws GRBException {

		double[][] testP = {{3,4,6},{8,6,3},{6,3,7},{0,7,5},{2,5,8},{8,6,4},{1,1,5},{8,4,2}};
		int[] testServers = {2,1,1};
		double[] testWeights = {1,2,3,1,2,3,1,2};
		COmKInstance instance = new COmKInstance(testP, testServers, testWeights);
		ThreeApproxLPSimplex lp = new ThreeApproxLPSimplex(instance, "none");
		lp.solve();

		System.out.println();
		System.out.println("Objective function");
		System.out.println(instance.getObjVal());
		System.out.println("Ordering");
		System.out.println(Arrays.toString(lp.getSigma()));
		System.out.println();
	}

	public RunThreeApprox() throws Throwable {
		double[][] testP = {{3,4,6},{8,6,3},{6,3,7},{0,7,5},{2,5,8},{8,6,4},{1,1,5},{8,4,2}};
		int[] testServers = {2,1,1};
		double[] testWeights = {1,2,3,1,2,3,1,2};
		COmKInstance instance = new COmKInstance(testP, testServers, testWeights);
		ThreeApproxLPSimplex lp = new ThreeApproxLPSimplex(instance, "none");
		lp.solve();
		v = instance.getObjVal();
		s = lp.getSigma();
	}
}
