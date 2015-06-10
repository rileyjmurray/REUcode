import gurobi.*;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.*;

public class CPmK {

	private static int n; // number of jobs
	private static int m; // number of data centers
	private static int r = 2; // number of servers
	private static double bigM = Math.pow(10, 6);
	private static int[][] p;
	private static int[] w;
	private static PrintWriter out;

	public static void main(String[] args) throws Throwable {
		PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter("output.txt")));
		int p[][] = {{1,2},{3,1},{2,3},{1,1},{3,2}};
		int w[] = {1,2,3,4,5};
		new CPmK(p, w, output);
		output.close();
		System.exit(0);
	}

	public CPmK(int[][] procTimes, int[] weight, PrintWriter output) throws Throwable {
		p = procTimes;
		w = weight;
		n = p.length;
		m = p[0].length;
		out = output;
		out.println(solveIP());
	}

	public static int solveIP() throws Throwable {
		GRBEnv env = new GRBEnv("CPmK.log"); //logistics
		GRBModel model = new GRBModel(env);

		/** ADDING VARIABLES HERE*/
		TreeMap<String, GRBVar> X = new TreeMap<String, GRBVar>(); // server precedence
		TreeMap<String, GRBVar> Y = new TreeMap<String, GRBVar>(); // precedence
		TreeMap<String, GRBVar> Z = new TreeMap<String, GRBVar>(); // start times
		TreeMap<String, GRBVar> S = new TreeMap<String, GRBVar>(); // server assignment
		TreeMap<Integer, GRBVar> C = new TreeMap<Integer, GRBVar>(); // completion times

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				for (int i2 = 1; i2 <= n; i2++) {
					if (i1 != i2) {
						for (int l = 1; l <= r; l++) {
							String label = k+","+i1+","+i2+","+l;
							X.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "x_"+label)); // x
						}
						String label = k+","+i1+","+i2;
						Y.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "y_"+label)); // y
					}
				}
				String label = k+","+i1;
				Z.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.INTEGER, "z_"+label)); // z
				
				for (int l = 1; l <= r; l++) {
					label = k+","+i1+","+l;
					S.put(label, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.BINARY, "s_"+label)); // s
				}
				
			}
		}

		for (int i = 1; i <= n; i++) {
			C.put(i, model.addVar(0.0, Integer.MAX_VALUE, 0.0, GRB.INTEGER, "C_"+i)); // completion times
		}

		model.update();

		/** ADDING CONSTRAINTS HERE*/
		GRBLinExpr ys = new GRBLinExpr();
		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				for (int i2 = 1; i2 <= n; i2++) {
					if (i1 != i2) {
						ys.addTerm(2.0, Y.get(k+","+i1+","+i2));
						System.out.println("Adding y_"+k+","+i1+","+ i2);
						for (int l = 1; l <= r; l++) {
							GRBLinExpr left = new GRBLinExpr();
							left.addTerm(1.0, Y.get(k+","+i1+","+i2));
							GRBLinExpr right = new GRBLinExpr();
							right.addTerm(1.0, X.get(k+","+i1+","+i2+","+l));
							model.addConstr(left, GRB.GREATER_EQUAL, right, "1");
							
							GRBLinExpr expr = new GRBLinExpr();
							expr.addTerm(1.0, S.get(k+","+i1+","+l));
							expr.addTerm(1.0, S.get(k+","+i2+","+l));
							expr.addTerm(1.0, Y.get(k+","+i1+","+i2));
							expr.addTerm(-3.0, X.get(k+","+i1+","+i2+","+l));
							model.addConstr(expr, GRB.LESS_EQUAL, 2.0, "8");
							
							
						}
						GRBLinExpr left = new GRBLinExpr();
						left.addTerm(bigM, Y.get(k+","+i1+","+i2));
						GRBLinExpr right = new GRBLinExpr();
						right.addTerm(1.0, Z.get(k+","+i2));
						right.addTerm(-1.0, Z.get(k+","+i1));
						model.addConstr(left, GRB.GREATER_EQUAL, right, "4");
						
						if (k!=m) {
							model.addConstr(Y.get(k+","+i1+","+i2), GRB.EQUAL, Y.get((k+1)+","+i1+","+i2), "6");
						}
						
					}
				}
				GRBLinExpr left = new GRBLinExpr();
				left.addTerm(1.0, C.get(i1));
				left.addTerm(-1.0, Z.get(k+","+i1));
				model.addConstr(left, GRB.GREATER_EQUAL, p[i1-1][k-1], "7");
			}
		}
		System.out.println(n*(n-1));
		model.addConstr(ys, GRB.EQUAL, m*n*(n-1), "no");

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				for (int i2 = 1; i2 < i1; i2++) {
					GRBLinExpr sum = new GRBLinExpr();
					for (int l = 1; l <= r; l++) {
						sum.addTerm(1.0, X.get(k+","+i1+","+i2+","+l));
						sum.addTerm(1.0, X.get(k+","+i2+","+i1+","+l));
					}
					model.addConstr(sum, GRB.LESS_EQUAL, 1.0, "2");
					
					GRBLinExpr left = new GRBLinExpr();
					left.addTerm(1.0, Y.get(k+","+i1+","+i2));
					left.addTerm(1.0, Y.get(k+","+i2+","+i1));
					//System.out.println("making y for jobs "+i1+","+i2);
					//System.out.println(Y.get(k+","+i1+","+i2) + " " + Y.get(k+","+i2+","+i1));
					model.addConstr(left, GRB.EQUAL, 1.0, "5");
				}
			}
		}

		for (int k = 1; k <= m; k++) {
			for (int i1 = 1; i1 <= n; i1++) {
				GRBLinExpr sum2 = new GRBLinExpr();
				for (int l = 1; l <= r; l++) {
					sum2.addTerm(1.0, S.get(k+","+i1+","+l));
					GRBLinExpr sum = new GRBLinExpr();
					for (int i2 = 1; i2 <= n; i2++) {
						if (i1 != i2) {
							sum.addTerm(p[i2-1][k-1], X.get(k+","+i2+","+i1+","+l));
						}
					}
					model.addConstr(sum, GRB.LESS_EQUAL, Z.get(k+","+i1), "3");
				}
				model.addConstr(sum2, GRB.EQUAL, 1.0, "9");
			}
		}
		
		for (int i1 = 1; i1 <= n; i1++) {
			for (int i2 = 1; i2 <= n; i2++) {
				for (int i3 = 1; i3 <= n; i3++) {
					if (i1 != i2 && i2 != i3 && i1!=i3) {
						GRBLinExpr expr = new GRBLinExpr();
						expr.addTerm(1.0,Y.get("1,"+i1+","+i2));
						expr.addTerm(1.0,Y.get("1,"+i2+","+i3));
						expr.addTerm(-2.0,Y.get("1,"+i1+","+i3));
						model.addConstr(expr, GRB.LESS_EQUAL, 1.0, "transitivity");
					}
				}
			}
		}
		
		model.update();
		
		/** SET OBJECTIVE FUNCTION */
		GRBLinExpr sum = new GRBLinExpr();
		for (int i = 1; i <= n; i++) {
			sum.addTerm(w[i-1], C.get(i));
		}
		model.setObjective(sum, GRB.MINIMIZE);
		model.update();

		/** SOLVE IP */
		model.getEnv().set(GRB.IntParam.OutputFlag, 0); // suppress Gurobi output
		model.optimize();
		int status = model.get(GRB.IntAttr.Status);	// 2 opt; 3 infeas; 9 timed out

		if (status == GRB.Status.OPTIMAL) {
			int x[][][][] = new int[m][n][n][r];
			for (String k: X.keySet()) {
				StringTokenizer st = new StringTokenizer(k,",");
				int j = Integer.parseInt(st.nextToken())-1;
				int i1 = Integer.parseInt(st.nextToken())-1;
				int i2 = Integer.parseInt(st.nextToken())-1;
				int l = Integer.parseInt(st.nextToken())-1;
				x[j][i1][i2][l] = (int)(X.get(k).get(GRB.DoubleAttr.X));
			}
			
			int y[][][] = new int[m][n][n];
			int yTotal = 0;
			for (String k: Y.keySet()) {
				System.out.print("y_"+k+": ");
				StringTokenizer st = new StringTokenizer(k,",");
				int j = Integer.parseInt(st.nextToken())-1;
				int i1 = Integer.parseInt(st.nextToken())-1;
				int i2 = Integer.parseInt(st.nextToken())-1;
				y[j][i1][i2] = (int)(Y.get(k).get(GRB.DoubleAttr.X));
				System.out.println(y[j][i1][i2]);
				yTotal+= y[j][i1][i2];
			} System.out.println(yTotal);
			System.out.println();
			
			int z[][] = new int[m][n];
			for (String k: Z.keySet()) {
				StringTokenizer st = new StringTokenizer(k,",");
				int j = Integer.parseInt(st.nextToken())-1;
				int i = Integer.parseInt(st.nextToken())-1;
				z[j][i] = (int)(Z.get(k).get(GRB.DoubleAttr.X));
			}

			int s[][][] = new int[m][n][r];
			for (String k: S.keySet()) {
				StringTokenizer st = new StringTokenizer(k,",");
				int j = Integer.parseInt(st.nextToken())-1;
				int i = Integer.parseInt(st.nextToken())-1;
				int l = Integer.parseInt(st.nextToken())-1;
				s[j][i][l] = (int)(S.get(k).get(GRB.DoubleAttr.X));
			}
			
			TreeMap<String,ArrayList<int[]>> chart = new TreeMap<String,ArrayList<int[]>>();
			for (int k = 0; k < m; k++) {
				for (int i = 0; i < n; i++) {
					for (int l = 0; l < r; l++) {
						if (s[k][i][l] == 1) {
							String key = (k+1) + "," + (l+1);
							ArrayList<int[]> a = new ArrayList<int[]>();
							int index = 0;
							if (chart.containsKey(key)) {
								a = chart.get(key);
								while (index < a.size() && a.get(index)[1] < z[k][i]) {
									index++;
								}
							}
							int[] b = {(i+1), z[k][i]};
							a.add(index, b);
							chart.put(key, a);
						}
					}
				}
			}
			
			for (int j = 0; j < m; j++) {
				System.out.println("DC "+(j+1));
				for (int l = 0; l < r; l++) {
					System.out.print("S"+(l+1)+": ");
					for (int i1 = 0; i1 < n; i1++) {
						for (int i2 = 0; i2 < n; i2++) {
							if (i1 != i2 && x[j][i1][i2][l] == 1) {
								System.out.print((i1+1)+"<"+(i2+1)+", ");
							}
						}
					}
					System.out.println();
				}
				System.out.println();
			}
			
			for (int i1 = 0; i1 < n; i1++) {
				System.out.print((i1+1)+" < ");
				for (int i2 = 0; i2 < n; i2++) {
					if (i1 != i2 && y[0][i1][i2] == 1) {
						System.out.print((i2+1)+",");
					}
				}
				System.out.println();
			}
			
			ArrayList<Integer> jobs = new ArrayList<Integer>();
			jobs.add(1);
			for (int i = 1; i < n; i++) {
				int index = 0;
				while (index < jobs.size() && y[0][i][jobs.get(index)-1] == 0) {
					index++;
				}
				jobs.add(index,(i+1));
			}
			
			System.out.print("Ordering: ");
			System.out.println(jobs);
			System.out.println();
			
			for (String key: chart.keySet()) {
				System.out.print(key+": ");
				StringTokenizer st = new StringTokenizer(key,",");
				int dc = Integer.parseInt(st.nextToken());
				for (int[] pair: chart.get(key)) {
					int i = pair[0];
					int t = pair[1];
					System.out.print("J"+i+"["+t+","+(t+p[i-1][dc-1])+"), ");
				}
				System.out.println();
			}
			System.out.println();
			
			int c[] = new int[n];
			double total = 0;
			double wTotal = 0;
			for (Integer i: C.keySet()) {
				System.out.print("C_"+i+": ");
				c[i-1] = (int)(C.get(i).get(GRB.DoubleAttr.X));
				System.out.println(c[i-1] + "\tW_"+i+": "+w[i-1]);
				total += c[i-1];
				wTotal += w[i-1]*c[i-1];
			}
			System.out.println();
			
			System.out.println("Completion time: " + total);
			System.out.println("Weighted completion time: " + wTotal);
			
		}

		else if (status == GRB.Status.INFEASIBLE) {
			System.out.println("infeasible");
		}

		else if (status == GRB.Status.TIME_LIMIT){	// timed out
			System.out.println("timed out");
		}

		else {
			System.err.println("unknown Gurobi status: " + status);
			System.exit(2);
		}

		// ----- clean up
		model.dispose();
		env.dispose();
		return 0;
	}

}