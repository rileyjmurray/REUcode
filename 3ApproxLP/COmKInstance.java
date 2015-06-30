
import java.util.Arrays;

public class COmKInstance {

	// Problem input
	public double[][] p;
	public DataCenter[] dcs;
	public int n;
	public int m;
	public double[] w;
	
	// Problem output
	private double objVal;
	private boolean isSolved;

	public COmKInstance(double[][] inP, int[] inServers, double[] inW) {
		p = inP;
		n = p.length;
		m = p[1].length;
		dcs = new DataCenter[m];
		w = inW;
		isSolved = false;
		for (int i = 0; i < m; i++) {
			dcs[i] = new DataCenter(inServers[i]);
		}
	}

	public double getObjVal() {
		return objVal;
	}

	public void setObjVal(double in) {
		objVal = in;
	}

	public boolean getIsSolved() {
		return isSolved;
	}

	public void listSchedule(int[] sigma) {
		if (sigma.length != n || isSolved) {
			throw new IllegalArgumentException();
		}
		objVal = 0.0;
		// for all jobs
		for (int i = 0; i < n; i++) {
			int job = sigma[i];
			double latest = 0;
			// find the latest completion time across DataCenters
			for (int l = 0; l < m; l++) {
				if (p[job][l] > 0) {
					double localTime = dcs[l].scheduleJobOnMinServer(job, p[job][l]);
					if (localTime > latest) {
						latest = localTime;
					}
				}
			}
			// record the objective value
			objVal = objVal + w[job] * latest;
		}
		isSolved = true;
	}

	public void multiListSchedule(int[][] multiSigma) {
		// multiSigma[dc] is the permutation of {1,...,n} for DataCenter "dc"
		double[] latest = new double[n];
		for (int dc = 0; dc < m; dc++) {
			for (int j = 0; j < n; j++) {
				int job = multiSigma[dc][j];
				if (p[job][dc] > 0) {
					double localTime = dcs[dc].scheduleJobOnMinServer(job, p[job][dc]);
					if (localTime > latest[job]) {
						latest[job] = localTime;
					}
				}
			}
		}
		for (int j = 0; j < n; j++) {
			objVal = objVal + w[j] * latest[j];
		}
		isSolved = true;
	}

}
