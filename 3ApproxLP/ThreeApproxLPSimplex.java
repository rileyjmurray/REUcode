


import gurobi.*;
import java.util.Arrays;

public class ThreeApproxLPSimplex {

	public static final long TIME_LIMIT = 50000;
	public static final double INIT_VIO = 0.0;

	// internal
	private COmKInstance problem;
	private GRBEnv env;
	private GRBModel model;
	// outputs
	private int[] sigma;
	private double lpObjective;

	public ThreeApproxLPSimplex(COmKInstance c, String initPolicy) {
		problem = c;
		try {
			env = new GRBEnv("ThreeApproxLPSimplex.log");
			model = new GRBModel(env);
			model.getEnv().set(GRB.IntParam.LogToConsole, 0); // do not print to console
			//model.getEnv().set(GRB.IntParam.DisplayInterval, 300); // 5 minute logging
			model.getEnv().set(GRB.IntParam.Threads, 4); // use 4 cores
			defineDecisionVariables();
			initializeConstraints(initPolicy);
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	private void defineDecisionVariables() throws GRBException {
		for (int i = 0; i < problem.n; i++) {
			model.addVar(0.0, Integer.MAX_VALUE, problem.w[i], GRB.CONTINUOUS, "C_" + i);
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
				model.addConstr(model.getVarByName("C_" + i), GRB.GREATER_EQUAL, problem.p[i][dc], "");
			}
		}
		model.update();
	}

	public int[] getSigma() {
		return sigma;
	}

	public double getLPObjective() {
		return lpObjective;
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
			constructSigma();
			problem.listSchedule(sigma);
			lpObjective = model.get(GRB.DoubleAttr.ObjVal);
		} else {
			problem.setObjVal(-1);
		}
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

	/*
	*  returns "true" if an unlisted constraint was violated. Also adds one or more constraints to the model
	*	For now, adds MOST violated constraints to the model for each DataCenter
	*	Later, should be able to add-all or add-worst then return
	*/
	private boolean infeasible() throws GRBException {
		boolean result = false;
		double[] values = new double[problem.n];
		for (int j = 0; j < problem.n; j++) {
			values[j] = model.getVarByName("C_" + j).get(GRB.DoubleAttr.X);
		}
		for (int i = 0; i < problem.m; i++) {
			int[] order = computeOrderByMetric(i, values);
			// order must be defined at this point...
			double extremeV = INIT_VIO;
			int extremeT = -1;
			for (int t = 0; t < problem.n; t++) {
				double v = calculateViolation(order, t, i, values);
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

	private int[] computeOrderByMetric(int dc, double[] compTimes) {
		double[] metric = new double[problem.n];
		Twople[] toSort = new Twople[problem.n];
		for (int j = 0; j < problem.n; j++) {
			metric[j] = compTimes[j]- 0.5 * problem.p[j][dc];
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
			sum = sum + problem.p[i][dc];
			sumOfSquares = sumOfSquares + problem.p[i][dc] * problem.p[i][dc];
			lhs.addTerm(problem.p[i][dc], model.getVarByName("C_" + i));
		}
		double discount = (1 / (double) problem.dcs[dc].servers.size());
		rhs = 0.5 * (sumOfSquares +  discount * sum * sum);
		model.addConstr(lhs, GRB.GREATER_EQUAL, rhs, "");
		model.update();
	}

	private double calculateViolation(int order[], int t, int dc, double[] compTimes) throws GRBException {
		// return violation of sum-of-squares constraint for J = {0,1,...,t}
		double sumOfSquaresRHS = 0.0;
		double sumRHS = 0.0;
		double sumLHS = 0.0;
		for (int i = 0; i <= t; i++) {
			sumRHS = sumRHS + problem.p[i][dc];
			sumOfSquaresRHS = sumOfSquaresRHS + problem.p[i][dc] * problem.p[i][dc];
			sumLHS = sumLHS + problem.p[i][dc] * compTimes[i];
		}
		double discount = (1 / (double) problem.dcs[dc].servers.size());
		double rhs = 0.5 * (sumOfSquaresRHS +  discount * sumRHS * sumRHS);
		return (rhs - sumLHS);
	}

	public class Twople implements Comparable {
		private double sortByMe;
		private int toGetMeSorted;
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