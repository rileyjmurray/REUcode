import gurobi.*;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.*;

public class COmK {

	// Parameters
	private int n; // number of jobs
	private int m; // number of data centers
	private int[] servers;
	private double[][] p;
	private double[] w;
	// Decision Variables
	private TreeMap<String, GRBVar> X; // server precedence
	private	TreeMap<String, GRBVar> Y; // precedence
	private	TreeMap<String, GRBVar> Z; // start times
	private	TreeMap<String, GRBVar> S; // server assignment
	private	TreeMap<Integer, GRBVar> C; // completion times
	private TreeMap<String, GRBVar> R; // time a job spends on a server
	// Gurobi
	private static double bigM = 100000;
	private GRBEnv env;
	private GRBModel model;
	// Model Ouput
	private ArrayList<Integer[][][]> x;
	private int[][][] y;
	private ArrayList<Integer[][]> s;
	private double[][] z;
	private ArrayList<Double[][]> r;
	private double[] c;
	private int[] ordering;

	public static void main(String[] args) {
		try {
			PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter("output.txt")));
			double[][] p = {{1,2},{3,1},{2,3},{1,1},{3,2}};
			double[] w = {1,2,3,4,5};
			int[] serversArg = {2,2};
			COmK instance = new COmK(p, w, serversArg);
			instance.defineDecisionVariables();
			instance.buildConstraints();
			instance.setObjectiveFunction();
			instance.solveIP();
			instance.visualizeOutput();
			output.close();
			instance.model.dispose();
			instance.env.dispose();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (GRBException a) {
			a.printStackTrace();
		}
	}

	public COmK(double[][] procTimes, double[] weight, int[] serversArg) {
		p = procTimes;
		w = weight;
		n = p.length;
		m = p[0].length;
		servers = serversArg;
		try {
			env = new GRBEnv("CPmK.log");
			model = new GRBModel(env);
			model.getEnv().set(GRB.IntParam.OutputFlag, 0); // suppress Gurobi output
		} catch (GRBException e) {
			e.printStackTrace();
		}
	}

	public void defineDecisionVariables() throws GRBException {
		X = new TreeMap<String, GRBVar>(); // server precedence
		Y = new TreeMap<String, GRBVar>(); // precedence
		Z = new TreeMap<String, GRBVar>(); // start times
		S = new TreeMap<String, GRBVar>(); // server assignment
		C = new TreeMap<Integer, GRBVar>(); // completion times
		R = new TreeMap<String, GRBVar>(); // time a job spends on a server

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				for (int i2 = 1; i2 <= n; i2++) {
					if (i1 != i2) {
						// Then precedence indicators need to be defined.
						for (int l = 1; l <= servers[k - 1]; l++) {
							String label = k+","+i1+","+i2+","+l;
							X.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "x_"+label)); // x
						}
						String label = k+","+i1+","+i2;
						Y.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "y_"+label)); // y
					}
				}
				// All jobs need a start time on each DataCenter
				String label = k+","+i1;
				Z.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.CONTINUOUS, "z_"+label)); // z
				// Define indicators that a job could be on a given server.
				for (int l = 1; l <= servers[k - 1]; l++) {
					label = k+","+i1+","+l;
					S.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "s_"+label)); // s
					R.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.CONTINUOUS, "r_" + label)); // r
				}
				
			}
		}

		for (int i = 1; i <= n; i++) {
			C.put(i, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.CONTINUOUS, "C_"+i)); // completion times
		}

		model.update();
	}

	public void buildConstraints() throws GRBException {
		/*
		 * (1) : an ordering must be chosen for each datacenter
		 * (2) : a job-task must be on one and only one server
		 * (3a, 3b) : start times must respect the ordering between jobs
		 * (4a, 4b, 4c, 4d) : x_{k,i1,i2,l} if and only if i1 < i2 and both on same server
		 * (5a) : start times for a job-task on each server (zero if not on the server)
		 * (5b) : start times for a job on a datacenter
		 * (6) : transitivity in the job ordering
		 * (7) : the competion time for a job must be less than or equal to the completion time of all tasks
		 * (8) : all datacenters must have the same ordering
		 */

		/*
		 * Constriants that do NOT sum over any set of indicies
		 */

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {

				GRBLinExpr left7 = new GRBLinExpr();
				left7.addTerm(1.0, C.get(i1));
				left7.addTerm(-1.0, Z.get(k + "," + i1));
				model.addConstr(left7, GRB.GREATER_EQUAL, p[i1-1][k-1], "(7)");

				for (int i2 = 1; i2 <= n; i2++) {
					if (i1 != i2) {


						if (k != m) {
							GRBLinExpr left8 = new GRBLinExpr();
							GRBLinExpr right8 = new GRBLinExpr();
							left8.addTerm(1.0, Y.get(k + "," + i1 + "," + i2));
							right8.addTerm(1.0, Y.get((k + 1) + "," + i1 + "," + i2));
							model.addConstr(left8, GRB.EQUAL, right8, "(8)");
						}

						GRBLinExpr left3a = new GRBLinExpr();
						GRBLinExpr right3a = new GRBLinExpr();
						GRBLinExpr left3b = new GRBLinExpr();

						left3a.addTerm(bigM, Y.get(k + "," + i1 + "," + i2));
						right3a.addTerm(-1.0, Z.get(k + "," + i1));
						right3a.addTerm(1.0, Z.get(k + "," + i2));
						model.addConstr(left3a, GRB.GREATER_EQUAL, right3a, "(3a)");

						left3b.addTerm(-1.0, Z.get(k + "," + i1));
						left3b.addTerm(-1.0 * bigM, Y.get(k + "," + i1 + "," + i2));
						left3b.addTerm(1.0, Z.get(k + "," + i2));
						model.addConstr(left3b, GRB.GREATER_EQUAL, -1.0 * bigM, "(3b)");


						for (int l = 1; l <= servers[k-1]; l++) {
							GRBLinExpr left1 = new GRBLinExpr();
							left1.addTerm(1.0, Y.get(k + "," + i1 + "," + i2));
							left1.addTerm(1.0, Y.get(k + "," + i2 + "," + i1));
							model.addConstr(left1, GRB.EQUAL, 1.0, "(1)");

							GRBLinExpr left4abc = new GRBLinExpr();
							GRBLinExpr left4d = new GRBLinExpr();
							GRBLinExpr right4a = new GRBLinExpr();
							GRBLinExpr right4b = new GRBLinExpr();
							GRBLinExpr right4c = new GRBLinExpr();
							left4abc.addTerm(1.0, X.get(k + "," + i1 + "," + i2 + "," + l));
							right4a.addTerm(1.0, Y.get(k + "," + i1 + "," + i2));
							right4b.addTerm(1.0, S.get(k + "," + i1 + "," + l));
							right4c.addTerm(1.0, S.get(k + "," + i2 + "," + l));
							model.addConstr(left4abc, GRB.LESS_EQUAL, right4a, "(4a)");
							model.addConstr(left4abc, GRB.LESS_EQUAL, right4b, "(4b)"); 
							model.addConstr(left4abc, GRB.LESS_EQUAL, right4c, "(4c)");
							left4d.addTerm(1.0, S.get(k + "," + i1 + "," + l));
							left4d.addTerm(1.0, S.get(k + "," + i2 + "," + l));
							left4d.addTerm(1.0, Y.get(k + "," + i1 + "," + i2));
							left4d.addTerm(-1.0, X.get(k + "," + i1 + "," + i2 + "," + l));
							model.addConstr(left4d, GRB.LESS_EQUAL, 2.0, "(4d)");
						}

						for (int i3 = 1; i3 <= n; i3++) {
							if (i2 != i3 && i1 != i3) {
								GRBLinExpr left6 = new GRBLinExpr();
								left6.addTerm(1.0, Y.get(k + "," + i1 + "," + i2));
								left6.addTerm(1.0, Y.get(k + "," + i2 + "," + i3));
								left6.addTerm(-1.0, Y.get(k + "," + i1 + "," + i3));
								model.addConstr(left6, GRB.LESS_EQUAL, 1.0, "(6)");
							}
						}
					}
				}
			}
		}


		/*
		 * Constraints that DO sum over sets of indicies
		 */

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {

				GRBLinExpr left2 = new GRBLinExpr();
				GRBLinExpr left5b = new GRBLinExpr();
				GRBLinExpr right5b = new GRBLinExpr();
				right5b.addTerm(1.0, Z.get(k + "," + i1));

				for (int l = 1; l <= servers[k-1]; l++) {
					left2.addTerm(1.0, S.get(k + "," + i1 + "," + l));
					left5b.addTerm(1.0, R.get(k + "," + i1 + "," + l));
				}
				model.addConstr(left2, GRB.EQUAL, 1.0, "(2)");
				model.addConstr(left5b, GRB.EQUAL, right5b, "(5b)");
			}
		}

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				for (int l = 1; l <= servers[k-1]; l++) {
					GRBLinExpr left5a = new GRBLinExpr();
					GRBLinExpr right5a = new GRBLinExpr();
					right5a.addTerm(1.0, R.get(k + "," + i1 + "," + l));
					for (int i2 = 1; i2 <= n; i2++) {
						if (i1 != i2) {
							left5a.addTerm(p[i2-1][k-1], X.get(k + "," + i2 + "," + i1 + "," + l));
						}
					}
					model.addConstr(left5a, GRB.EQUAL, right5a, "(5a)");
				}
			}
		}
		model.update();
	}

	public void setObjectiveFunction() throws GRBException {
		/** SET OBJECTIVE FUNCTION */
		GRBLinExpr sum = new GRBLinExpr();
		for (int i = 1; i <= n; i++) {
			sum.addTerm(w[i-1], C.get(i));
		}
		model.setObjective(sum, GRB.MINIMIZE);
		model.update();
	}

	public void solveIP() throws GRBException {
		/** SOLVE IP */
		model.optimize();
		Integer status = model.get(GRB.IntAttr.Status);	// 2 opt; 3 infeas; 9 timed out
		if (status.equals(GRB.Status.OPTIMAL)) {
			populateVariableMatrices();
		} else if (status.equals(GRB.Status.INFEASIBLE)) {
			System.out.println("infeasible");
		} else if (status.equals(GRB.Status.TIME_LIMIT)) {
			System.out.println("timed out");
		} else {
			System.err.println("unknown Gurobi status: " + status);
		}
	}

	public void populateVariableMatrices() throws GRBException {
			
		// INITIALIZE CONTAINERS
		x = new ArrayList<Integer[][][]>();
		s = new ArrayList<Integer[][]>();
		r = new ArrayList<Double[][]>();
		for (int k = 1; k <= m; k++) {
			x.add(k-1, new Integer[n][n][servers[k - 1]]);
			s.add(k-1, new Integer[n][servers[k-1]]);
			r.add(k-1, new Double[n][servers[k-1]]);
		}
		y = new int[m][n][n];
		z = new double[m][n];
		c = new double[n];

		// POPULATE
		for (String k : X.keySet()) {
			StringTokenizer st = new StringTokenizer(k,",");
			int j = Integer.parseInt(st.nextToken())-1;
			int i1 = Integer.parseInt(st.nextToken())-1;
			int i2 = Integer.parseInt(st.nextToken())-1;
			int l = Integer.parseInt(st.nextToken())-1;
			x.get(j)[i1][i2][l] = (int) Math.round(X.get(k).get(GRB.DoubleAttr.X));
		}
		
		for (String k : Y.keySet()) {
			StringTokenizer st = new StringTokenizer(k,",");
			int j = Integer.parseInt(st.nextToken())-1;
			int i1 = Integer.parseInt(st.nextToken())-1;
			int i2 = Integer.parseInt(st.nextToken())-1;
			y[j][i1][i2] = (int) Math.round(Y.get(k).get(GRB.DoubleAttr.X));
		}

		for (String k : S.keySet()) {
			StringTokenizer st = new StringTokenizer(k,",");
			int j = Integer.parseInt(st.nextToken())-1;
			int i = Integer.parseInt(st.nextToken())-1;
			int l = Integer.parseInt(st.nextToken())-1;
			s.get(j)[i][l] = (int) Math.round(S.get(k).get(GRB.DoubleAttr.X));
		}

		for (String k : Z.keySet()) {
			StringTokenizer st = new StringTokenizer(k,",");
			int j = Integer.parseInt(st.nextToken())-1;
			int i = Integer.parseInt(st.nextToken())-1;
			z[j][i] = Z.get(k).get(GRB.DoubleAttr.X);
		}

		for (Integer k : C.keySet()) {
			int i = (int) k - 1;
			c[i] = C.get(k).get(GRB.DoubleAttr.X);
		}

		for (String k : R.keySet()) {
			StringTokenizer st = new StringTokenizer(k, ", ");
			int j = Integer.parseInt(st.nextToken()) - 1;
			int i = Integer.parseInt(st.nextToken()) - 1;
			int l = Integer.parseInt(st.nextToken()) - 1;
			r.get(j)[i][l] = R.get(k).get(GRB.DoubleAttr.X);
		}
	}

	public void visualizeOutput() throws GRBException {
		// Display ordering
		findAndDisplayOrdering();
		displayChart();
	}

	public void findAndDisplayOrdering() {
		System.out.println();
		ordering = new int[n];
		for (int i1 = 0; i1 < n; i1++) {
			StringBuilder sb = new StringBuilder();
			int pos = 0;
			sb.append("Job " + (i1 + 1) + " < ");
			for (int i2 = 0; i2 < n; i2++) {
				if (y[0][i1][i2] == 1) {
					sb.append((i2 + 1) + ", ");
					pos = pos + 1;
				}
			}
			ordering[(n - 1) - pos] = (i1 + 1);
			System.out.println(sb.toString());
		}
		System.out.println();
		System.out.println(Arrays.toString(ordering));
	}

	public void displayChart() {
		for (int k = 0; k < m; k++) {
			System.out.println();
			StringBuilder[] sb = new StringBuilder[servers[k]];
			for (int l = 0; l < servers[k]; l++) {
				sb[l] = new StringBuilder();
			}
			for (int i = 0; i < n; i++) {
				int currJob = ordering[i] - 1;
				int jobServer = 0;
				while (s.get(k)[currJob][jobServer].equals(0)) {
					jobServer = jobServer + 1;
				}
				String start = String.format("J" + (currJob + 1) + "[%.2f, ",z[k][currJob]);
				String end = String.format("%.2f) ", (z[k][currJob] + p[currJob][k]));
				sb[jobServer].append(start + end);
			}
			for (int l = 0; l < servers[k]; l++) {
				System.out.println(sb[l].toString());
			}
		}
		System.out.println();

	}


}