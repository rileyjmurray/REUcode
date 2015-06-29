
import gurobi.*;
import java.util.Arrays;

public class LPMLInterface {

	private COmKInstance instance;
	private ThreeApproxLPSimplex lp;

	public LPMLInterface(double[][] testP, int[] testServers, double[] testWeights, String policy) throws GRBException {
		instance = new COmKInstance(testP, testServers, testWeights);
		lp = new ThreeApproxLPSimplex(instance, policy);
		lp.solve();
	}

	public LPMLInterface() {
		
	}

	public double getObjVal() {
		return instance.getObjVal();
	}

	public String getOrderingString() {
		return Arrays.toString(lp.getSigma());
	}

	public int[] getOrderingArray() {
		return lp.getSigma();
	}
}
