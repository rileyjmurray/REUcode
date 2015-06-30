


import gurobi.*;
import java.util.Arrays;

public class ThreeApproxLPSimplex {

	public static final long TIME_LIMIT = 30000;
	public static final double INIT_VIO = 0.0;
	public static final double EPSILON = (1.0 / 10000.0);

	// internal
	private COmKInstance problem;
	private GRBEnv env;
	private GRBModel model;
	// outputs
	private int[] sigma;
	private int[][] multiSigma;
	private double lpObjective;
	private double[][] compTimes;

	public ThreeApproxLPSimplex(COmKInstance c, String initPolicy) {
		problem = c;
		try {
			env = new GRBEnv("ThreeApproxLPSimplex.log");
			model = new GRBModel(env);
			model.getEnv().set(GRB.IntParam.LogToConsole, 0); // do not print to console
			model.getEnv().set(GRB.IntParam.DisplayInterval, 300); // 5 minute logging
			model.getEnv().set(GRB.IntParam.Threads, 4); // use 4 cores
			defineDecisionVariables();
			initializeConstraints(initPolicy);
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	private void defineDecisionVariables() throws GRBException {
		for (int j = 0; j < problem.n; j++) {
			model.addVar(0.0, Integer.MAX_VALUE, problem.w[j], GRB.CONTINUOUS, "C_" + j);
			for (int i = 0; i < problem.m; i++) {
				model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.CONTINUOUS, "C_" + i + "," + j);
			}
		}
		model.update();
	}


	private void initializeConstraints(String policy) throws GRBException {
		// scheduling polytope constraints, use stated policy
		if (policy.equals("naive")) {
			int[] order = new int[problem.n];
			for (int i = 0; i < problem.n; i++) {
				order[i] = i;
			}
			for (int dc = 0; dc < problem.m; dc++) {
				for (int i = 0; i < problem.n; i++) {
					addConstraint(order, i, dc);
				}
			}
		} else if (policy.equals("none")) {
			// only add sanity constraints
		} else {
			throw new IllegalArgumentException();
		}
		// sanity constraints
		for (int dc = 0; dc < problem.m; dc++) {
			for (int i = 0; i < problem.n; i++) {
				model.addConstr(model.getVarByName("C_" + dc + "," + i), GRB.GREATER_EQUAL, problem.p[i][dc], "");
				model.addConstr(model.getVarByName("C_" + i), GRB.GREATER_EQUAL, model.getVarByName("C_" + dc + "," + i), "");
			}
		}
		model.update();
	}

	public int[] getSigma() {
		return sigma;
	}

	public int[][] getMultiSigma() {
		return multiSigma;
	}

	public double getLPObjective() {
		return lpObjective;
	}

	public double[] getCompTimesForJob(int i) {
		return compTimes[i];
	}

	public void solve() throws GRBException {
		long startTime = System.currentTimeMillis();
		long elapsedTime = 0;
		model.optimize();
		while(infeasible() && elapsedTime <= TIME_LIMIT) {
			model.reset();
			model.optimize();
			elapsedTime = System.currentTimeMillis() - startTime;
		}
		if (elapsedTime < TIME_LIMIT) {
			constructMultiSigma();
			constructCompTimes();
			problem.multiListSchedule(multiSigma);
			lpObjective = model.get(GRB.DoubleAttr.ObjVal);
		} else {
			problem.setObjVal(-1);
			lpObjective = -1;
		}
		model.dispose();
		env.dispose();
	}

	public void constructSigma() throws GRBException {
		Twople[] toSort = new Twople[problem.n];
		for (int i = 0; i < problem.n; i++) {
			toSort[i] = new Twople(model.getVarByName("C_" + i).get(GRB.DoubleAttr.X), i);
		}
		Arrays.sort(toSort);
		sigma = new int[problem.n];
		for (int i = 0; i < problem.n; i++) {
			sigma[i] = toSort[i].toGetMeSorted;
		}
	}

	public void constructMultiSigma() throws GRBException {
		multiSigma = new int[problem.m][problem.n];
		for (int dc = 0; dc < problem.m; dc++) {
			Twople[] toSort = new Twople[problem.n];
			for (int i = 0; i < problem.n; i++) {
				toSort[i] = new Twople(model.getVarByName("C_" + dc + "," + i).get(GRB.DoubleAttr.X), i);
			}
			Arrays.sort(toSort);
			multiSigma[dc] = new int[problem.n];
			for (int i = 0; i < problem.n; i++) {
				multiSigma[dc][i] = toSort[i].toGetMeSorted;
			}
		}
	}

	public void constructCompTimes() throws GRBException {
		compTimes = new double[problem.n][problem.m];
		for (int i = 0; i < problem.m; i++) {
			for (int j = 0; j < problem.n; j++) {
				compTimes[j][i] = model.getVarByName("C_" + i + "," + j).get(GRB.DoubleAttr.X);
			}
		}
	}

	/*
	*  returns "true" if an unlisted constraint was violated. Also adds one or more constraints to the model
	*	For now, adds MOST violated constraints to the model for each DataCenter
	*	Later, should be able to add-all or add-worst then return
	*/
	private boolean infeasible() throws GRBException {
		boolean result = false;
		double[][] values = new double[problem.m][problem.n];
		for (int i = 0; i < problem.m; i++) {
			for (int j = 0; j < problem.n; j++) {
				values[i][j] = model.getVarByName("C_" + i + "," + j).get(GRB.DoubleAttr.X);
			}
		}
		for (int i = 0; i < problem.m; i++) {
			int[] order = computeOrderByMetric(i, values[i]);
			// order must be defined at this point...
			double extremeV = INIT_VIO;
			int extremeT = -1;
			for (int t = 0; t < problem.n; t++) {
				double v = calculateViolation(order, t, i, values[i]);
				if (v > extremeV) {
					extremeV = v;
					extremeT = t;
				}
			}
			if (extremeT != -1) {
				result = true;
				addConstraint(order, extremeT, i);
			}
		}
		return result;
	}

	private int[] computeOrderByMetric(int dc, double[] ct) {
		double[] metric = new double[problem.n];
		Twople[] toSort = new Twople[problem.n];
		for (int j = 0; j < problem.n; j++) {
			metric[j] = ct[j] - 0.5 * problem.p[j][dc];
			toSort[j] = new Twople(metric[j], j);
		}
		// sort jobs in increasing order of metric established above (to define order)
		Arrays.sort(toSort);
		int[] order = new int[problem.n];
		for (int j = 0; j < problem.n; j++) {
			order[j] = toSort[j].toGetMeSorted;
		}
		return order;
	}

	private void addConstraint(int[] order, int t, int dc) throws GRBException {
		// add sum-of-squares constraint for J = {0,1,...,t}
		double sumOfSquares = 0.0;
		double sum = 0.0;
		double rhs = 0.0;
		GRBLinExpr lhs = new GRBLinExpr();

		for (int i = 0; i <= t; i++) {
			int job = order[i];
			sum = sum + problem.p[job][dc];
			sumOfSquares = sumOfSquares + problem.p[job][dc] * problem.p[job][dc];
			lhs.addTerm(problem.p[job][dc], model.getVarByName("C_" + dc + "," + job));
		}
		double discount = (1 / (double) problem.dcs[dc].servers.size());
		rhs = 0.5 * (sumOfSquares +  discount * sum * sum);
		model.addConstr(lhs, GRB.GREATER_EQUAL, rhs, "");
		model.update();
	}

	private double calculateViolation(int order[], int t, int dc, double[] ct) throws GRBException {
		// return violation of sum-of-squares constraint for J = {0,1,...,t}
		double sumOfSquaresRHS = 0.0;
		double sumRHS = 0.0;
		double sumLHS = 0.0;
		for (int i = 0; i <= t; i++) {
			int job = order[i];
			sumRHS = sumRHS + problem.p[job][dc];
			sumOfSquaresRHS = sumOfSquaresRHS + problem.p[job][dc] * problem.p[job][dc];
			sumLHS = sumLHS + problem.p[job][dc] * ct[job];
		}
		double discount = (1 / (double) problem.dcs[dc].servers.size());
		double rhs = 0.5 * (sumOfSquaresRHS +  discount * sumRHS * sumRHS);
		return (rhs - sumLHS);
	}

	public static class Twople implements Comparable {
		public double sortByMe;
		public int toGetMeSorted;
		public Twople(double sbm, int tgms) {
			sortByMe = sbm;
			toGetMeSorted = tgms;
		}
		public int compareTo(Object o) {
			if (o instanceof Twople && o != null) {
				Twople other = (Twople) o;
				if (other == null) {
					throw new RuntimeException();
				}
				double delta = sortByMe - other.sortByMe;
				if (delta < 0) {
					return -1;
				} else if (delta == 0) {
					return 0;
				} else {
					return 1;
				}
			} else {
				throw new IllegalArgumentException();
			}
		}
	}


}