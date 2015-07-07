
import gurobi.*;
import java.util.Arrays;

public class RunThreeApprox {

	public double v;
	public int[] s;

	public static void main(String[] args) throws GRBException {

		double[][] testP = {
			{46,24},
			{2,8},
			{35,18},
			{24,7},
			{42,15},
			{39,49},
			{21,23},
			{48,32},
			{18,5},
			{46,44},
			{39,29},
			{4,10},
			{42,35},
			{35,45},
			{41,28},
			{37,5},
			{41,26},
			{39,46},
			{9, 28},
			{42, 2}};
		int[] testServers = {1, 4};
		double[] testWeights = {
			25.4271,
		   39.6015,
		   14.6035,
		    1.9723,
		    4.6457,
		   37.0032,
		   24.7842,
		   36.2614,
		   20.3839,
		   32.6429,
		   47.4194,
		   39.5773,
		    4.0410,
		   39.7962,
		   19.8361,
		   24.4642,
		    1.6690,
		   42.1837,
		   25.3520,
		   31.4506};
		COmKInstance instance = new COmKInstance(testP, testServers, testWeights);
		ThreeApproxLPSimplex lp = new ThreeApproxLPSimplex(instance, "none", "single-permutation");
		lp.solve();

		boolean valid = (lp.formulation.equals("single-permutation") || lp.formulation.equals("multi-permutation"));
		if (valid) {
			System.out.println();
			System.out.println("Formulation Type: " + lp.formulation);
			System.out.println();
			System.out.println("Objective function");
			System.out.println(instance.getObjVal());
			System.out.println("LP Objective");
			System.out.println(lp.getLPObjective());
			System.out.println("Worst-Case Optimality Gap");
			System.out.println(instance.getObjVal() / lp.getLPObjective());
			System.out.println();

			COmKInstance instance2 = new COmKInstance(testP, testServers, testWeights);
			System.out.println();
			System.out.println("4-Approximation Results");
			instance2.transformThenMonaldo();
			System.out.println();
			System.out.println("Objective function");
			System.out.println(instance2.getObjVal());
			System.out.println("Worst-Case Optimality Gap");
			System.out.println(instance2.getObjVal() / lp.getLPObjective());
			System.out.println();
		} else {
			System.out.println("INVALID FORMULATION");
		}	
	}

}
