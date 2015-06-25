
import java.util.HashMap;
import gurobi.*;

public class BadRatioFinder {
	
	// Problem input
	private double[][] p;
	private int[] servers;
	private double[] sol;
	private double[][] finTimes;
	private HashMap<String, Integer[]> perms;
	private int n;
	private int m;
	// Problem output
	private double[] w;
	private double delta;

	public BadRatioFinder(double[][] inP, int[] inServers, double[] inSol) {
		p = inP;
		servers = inServers;
		sol = inSol;
		n = p.length;
		m = p[1].length;
	}

	public double[] getW() {
		if (w != null) {
			double[] out = new double[w.length];
			System.arraycopy(w, 0, out, 0, w.length);
			return out;
		}
		return null;
	}

	public double getDelta() {
		return delta;
	}

	public void computeLPCoefficients() {
		// Compute all n! possible outputs as a result of single-permutation schedule
		// 	store each permutation is a string, map the string to a Double[] of completion times

		// store all permutions in the "perms" map.
		this.computeAllPermutationsUpTo9();

		int permNo = 0;
		for (Integer[] sigma : perms.values()) {

			// initialize all DataCenters
			DataCenter[] dc = new DataCenter[m];
			for (int l = 0; l < m; l++) {
				dc[l] = new DataCenter(this.servers[l]);
			}

			// process jobs in order proscribed by permutation
			for (int j = 0; j < n; j++) {
				int job = (int) sigma[j];
				double latest = 0;
				for (int l = 0; l < m; l++) {
					if (p[job][l] > 0) {
						double localTime = dc[l].scheduleJobOnMinServer(job, p[job][l]);
						if (localTime > latest) {
							latest = localTime;
						}
					}
				}
				finTimes[permNo][job] = latest;
			}
			permNo = permNo + 1;
		}

	}

	public void constructAndSolveLP() {
		try {
			BadRatioLP lp = new BadRatioLP(p, servers, sol, finTimes);
			lp.solve();
			delta = lp.getDelta();
			w = lp.getW();
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	public void computeAllPermutationsUpTo9() {
		int fact = BadRatioFinder.factorial(n);
		perms = new HashMap<String, Integer[]>();
		finTimes = new double[fact][n];
		StringBuilder sb = new StringBuilder();
		sb.append("0");
		for (int i = 1; i < n; i ++) {
			sb.append("" + i);
		}
		perm1(sb.toString());
	}

	public void perm1(String s) { perm1("", s); }

	private void perm1(String prefix, String s) {
        int N = s.length();
        if (N == 0) {
        	// prefix needs to be converted to a Double[]
        	Integer[] vec = new Integer[n];
        	for (int i = 0; i < prefix.length(); i++) {
        		try {
        			char c = prefix.charAt(i);
        			vec[i] = Integer.parseInt("" + c);
        		} catch (NumberFormatException e) {
        			e.printStackTrace();
        		}
        	}
        	perms.put(prefix, vec);
        } else {
            for (int i = 0; i < N; i++) {
               perm1(prefix + s.charAt(i), s.substring(0, i) + s.substring(i+1, N));
            }
        }
    }

	public static int factorial(int x) {
		int y = x;
		while (x > 1) {
			x = x - 1;
			y = y * x;
		}
		return y;
	}
}
