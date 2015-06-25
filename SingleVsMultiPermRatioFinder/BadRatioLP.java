
import gurobi.*;
import java.util.TreeMap;

public class BadRatioLP {

	// Problem input
	private double[][] p;
	private int[] servers;
	private double[] sol;
	private double sumSol;
	private double[][] finTimes;
	private int n;
	private int m;
	// gurobi
	private GRBEnv env;
	private GRBModel model;
	// Decision variables and constraints
	private GRBVar[] W;
	private GRBVar ratio;
	private TreeMap<String, GRBConstr> constraints;
	// Output
	private double[] wStar;
	private double deltaStar;

	public BadRatioLP(double[][] inP, int[] inServers, double[] inSol, double[][] inFinTimes) throws GRBException {
		p = inP;
		servers = inServers;
		sol = inSol;
		finTimes = inFinTimes;
		n = p.length;
		m = p[1].length;
		for (int i = 0; i < n; i++) {
			sumSol = sumSol + sol[i];
		}
		try {
			env = new GRBEnv("BadRatioLP.log");
			model = new GRBModel(env);
			model.set(GRB.IntAttr.ModelSense, -1); // maximization
			model.getEnv().set(GRB.IntParam.OutputFlag, 0); // suppress output
			model.update();
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	public void defineDecisionVariables() throws GRBException {
		W = new GRBVar[n];
		for (int i = 0; i < n; i++) {
			W[i] = model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.CONTINUOUS, "" + i);
		}
		ratio = model.addVar(0.0, Integer.MAX_VALUE, 1.0, GRB.CONTINUOUS, "objective");
		model.update();
	}

	public void buildConstraints() throws GRBException {
		// define n! permutation constraints
		for (int i = 0; i < finTimes.length; i++) {
			GRBLinExpr rhs = new GRBLinExpr();
			for (int j = 0; j < n; j++) {
				rhs.addTerm(finTimes[i][j], W[j]);
			}
			model.addConstr(ratio, GRB.LESS_EQUAL, rhs, "" + i);
		}
		// define sum-to-1 constraint.
		GRBLinExpr sumTo1 = new GRBLinExpr();
		for (int j = 0; j < n; j++) {
			sumTo1.addTerm(sol[j] / sumSol, W[j]);
		}
		model.addConstr(sumTo1, GRB.EQUAL, 1.0, "convex combination");
		model.update();
	}

	public void solve() throws GRBException {
		defineDecisionVariables();
		buildConstraints();
		model.optimize();
		int status = model.get(GRB.IntAttr.Status);
		if (status == GRB.Status.OPTIMAL) {
			populateOutput();
		} else if (status == GRB.Status.INFEASIBLE) {
			System.out.println("infeasible");
		} else if (status == GRB.Status.TIME_LIMIT) {
			System.out.println("timed out");
		} else {
			System.err.println("unknown Gurobi status: " + status);
		}

	}

	public void populateOutput() throws GRBException {
		wStar = new double[n];
		for (int i = 0; i < n; i++) {
			wStar[i] = W[i].get(GRB.DoubleAttr.X);
		}
		deltaStar = model.get(GRB.DoubleAttr.ObjVal) / sumSol;
	}

	public double getDelta() {
		return deltaStar;
	}

	public double[] getW() {
		return wStar;
	}
}