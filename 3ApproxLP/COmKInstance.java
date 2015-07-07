
import java.util.Arrays;

public class COmKInstance {

	// constants
	private static final double BIG_NUM = 10000000000.0;
	private static final double TINY_NUM = 0.00000000001;

	// Problem input
	public double[][] p;
	public double[] maxP;
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
		maxP = new double[n];
		for (int j = 0; j < n; j++) {
			double currMax = p[j][0];
			for (int i = 1; i < m; i++) {
				if (currMax < p[j][i]) {
					currMax = p[j][i];
				}
			}
			maxP[j] = currMax;
		}
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

	public void transformThenMonaldo() {
		double[][] transP = new double[n][m + n];
		double[][] transPTranspose = new double[m + n][n];
		int[] transK = new int[m + n];
		for (int j = 0; j < n; j++) {
			for (int i = 0; i < m; i++) {
				transP[j][i] = p[j][i] / ((double) dcs[i].servers.size());
				transPTranspose[i][j] = transP[j][i];
			}
			transP[j][m + j] = maxP[j];
			transPTranspose[m + j][j] = transP[j][m + j];
		}
		int[] sigma = monaldo(transP, transPTranspose);
		listSchedule(sigma);
	}

	public int[] monaldo(double[][] inP, double[][] inPTranspose) {
		// assume K = 1 for all DC's
		double[] altW = new double[n];
		boolean[] scheduled = new boolean[n];
		for (int j = 0; j < n; j++) {
			altW[j] = w[j];
		}

		int[] toReturn = new int[inP.length];
		double[] load = new double[inP[1].length];
		for (int i = 0; i < inP[1].length; i++) {
			for (int j = 0; j < n; j++) {
				load[i] = load[i] + inP[j][i];
			}
		}
		
		for (int j = (n-1); j >= 0; j--) {
			int mu = findMax(load);
			// find the job on this bottleneck
			double[] times = inPTranspose[mu];
			double[] priority = elementByElementDivide(altW, times);
			int job = findMin(priority, scheduled);
			// schedule this job
			toReturn[j] = job;
			// update loads and weights
			double theta = altW[job] / inP[job][mu];
			updateWeights(altW, inPTranspose[mu], theta, scheduled);
			updateLoads(load, inP[job]);
			scheduled[job] = true;
		}
		return toReturn;
	}

	private void updateWeights(double[] wt, double[] inPMu, double theta, boolean[] sched) {
		for (int j = 0; j < n; j++) {
			if (!sched[j]) {
				wt[j] = Math.max(wt[j] - theta * inPMu[j], 0.0);
			}
		}
	}

	private void updateLoads(double[] l, double[] inP) {
		for (int i = 0; i < inP.length; i++) {
				l[i] = l[i] - inP[i];
		}
	}

	private double[] elementByElementDivide(double[] num, double[] den) {
		if (num.length != den.length) {
			throw new IllegalArgumentException("Dimensions don't match.");
		}
		double[] out = new double[num.length];
		for (int i = 0; i < num.length; i++) {
			if (den[i] < TINY_NUM) {
				out[i] = BIG_NUM;
			} else {
				out[i] = num[i] / den[i];
			}
		}
		return out;
	}

	private int findMax(double[] v) {
		// return index of min value of v
		int toReturn = 0;
		double currMax = 0.0;
		for (int i = 0; i < v.length; i++) {
			if (v[i] > currMax) {
				toReturn = i;
				currMax = v[i];
			}
		}
		return toReturn;
	}

	private int findMin(double[] v, boolean[] notCandidate) {
		// return index of min value of v
		int toReturn = 0;
		double currMin = BIG_NUM;
		for (int i = 0; i < v.length; i++) {
			if (!notCandidate[i] && v[i] < currMin) {
				toReturn = i;
				currMin = v[i];
			}
		}
		return toReturn;
	}

}
