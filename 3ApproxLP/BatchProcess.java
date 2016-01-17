
import java.io.*;
import java.util.Random;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.ArrayList;
import gurobi.*;

public class BatchProcess implements Serializable {

	public ArrayList<COmKInstance> threeAppx;
	public ArrayList<COmKInstance> fourAppx;
	public Random r;

	public BatchProcess(String inputFileName, long seed) throws GRBException {
		
		r = new Random(seed);
		threeAppx = new ArrayList<COmKInstance>();
		fourAppx = new ArrayList<COmKInstance>();

		DateFormat df = new SimpleDateFormat("MM-dd-yy-HH-mm-ss");
		Date today = Calendar.getInstance().getTime();        
		String reportDate = df.format(today);
		String outputFile = inputFileName + reportDate + ".txt";
        // This will reference one line at a time
        String line = null;
        try {
            // FileReader reads text files in the default encoding.
            FileReader fileReader = new FileReader(inputFileName);
            // Always wrap FileReader in BufferedReader.
            BufferedReader bufferedReader = new BufferedReader(fileReader);

			// open spec file
			line = bufferedReader.readLine();
			int numConfigs = Integer.parseInt(line);
			line = bufferedReader.readLine();
			int numReplications = Integer.parseInt(line);

			String key = "fourObj, threeObj, lowerBound, fourTime, threeTime";
			writeToFile(outputFile, key);

			long et = System.currentTimeMillis();
			for (int cfg = 0; cfg < numConfigs; cfg++) {

				// read specs for this configuration
				line = bufferedReader.readLine();
				if (line == null) {
					break;
				}
				String[] thisTrial = line.split(",");
				String dist = ""; double lowTime = 0.0; double noiseTime = 0.0; int n = 1; int m = 1;
				int lowK = 1; double noiseK = 1; double lowW = 1; double noiseW = 1;

				try {
					dist = thisTrial[0];
					lowTime = Double.parseDouble(thisTrial[1]);
					noiseTime = Double.parseDouble(thisTrial[2]);
					n  = Integer.parseInt(thisTrial[3]);
					m = Integer.parseInt(thisTrial[4]);
					lowK = Integer.parseInt(thisTrial[5]);
					noiseK = Double.parseDouble(thisTrial[6]);
					lowW = Double.parseDouble(thisTrial[7]);
					noiseW = Double.parseDouble(thisTrial[8]);
				} catch (NumberFormatException e) {
					e.printStackTrace();
				}

				System.out.println("Elapsed time: " + ((System.currentTimeMillis() - et) / 1000.0) 
					+ " Proportion Complete: " + cfg / ((double) numConfigs));

				for (int rep = 0; rep < numReplications; rep++) {
					// generate stuff for this trial
					int[] k = generateRandK(lowK, noiseK, m);
					double[][] p = generateRandPTMatrix(dist, lowTime, noiseTime, n, m, k);
					double[] w = generateRandW(lowW, noiseW, n);
					
					// define and solve instances

					// 4-Approximation
					COmKInstance to4Appx = new COmKInstance(p, k, w);
					long fourT = System.currentTimeMillis();
					to4Appx.transformThenMonaldo();
					fourT = System.currentTimeMillis() - fourT;
					double fourObj = to4Appx.getObjVal();
					
					// 3-Approximation
					COmKInstance to3Appx = new COmKInstance(p, k, w);
					long threeT = System.currentTimeMillis();
					ThreeApproxLPSimplex to3AppxLP = new ThreeApproxLPSimplex(to3Appx, "none");
					to3AppxLP.solve();
					threeT = System.currentTimeMillis() - threeT;
					double threeObj = to3Appx.getObjVal();
					double lowerBound = to3AppxLP.getLPObjective();

					// write output to file --> 
					//		all leading characters, then up to 8 decimal points
					//		convert time to seconds
					double threeTime = threeT / ((double) 1000.0);
					double fourTime = fourT / ((double) 1000.0);
					String output = String.format("%.8f, %.8f, %.8f, %.8f, %.8f", fourObj, threeObj, lowerBound, fourTime, threeTime);
					writeToFile(outputFile, output);

					threeAppx.add(to3Appx);
					fourAppx.add(to4Appx);
				}
			}
			// Always close files.
            bufferedReader.close();  
		} catch(FileNotFoundException ex) {
            System.out.println("Unable to open file '" + inputFileName + "'");                
        } catch(IOException ex) {
            System.out.println("Error reading file '" + inputFileName + "'");                   
        }
        System.out.println("************** DONE **************");
		serialize(inputFileName);
	}

	public double[][] generateRandPTMatrix(String dist, double low, double noise, int n, int m, int[] k) {
		double[][] toReturn = new double[n][m];
		for (int j = 0; j < n; j++) {
			toReturn[j] = new double[m];
			for (int i = 0; i < m; i++) {
				toReturn[j][i] = low + (noise * ((double) k[i]) *  r.nextDouble());
			}
		}
		return toReturn;
	}

	public int[] generateRandK(int low, double noise, int m) {
		int[] toReturn = new int[m];
		for (int i = 0; i < m; i++) {
			toReturn[i] = low + (int) Math.round(noise * r.nextDouble());
		}
		return toReturn;
	}

	public double[] generateRandW(double low, double noise, int n) {
		double[] toReturn = new double[n];
		for (int i = 0; i < n; i++) {
			toReturn[i] = low + noise * r.nextDouble();
		}
		return toReturn;
	}

	public void serialize(String fileName) {
		try {
			FileOutputStream fileOut = new FileOutputStream("/javaSer/"+ fileName +".ser");
			ObjectOutputStream out = new ObjectOutputStream(fileOut);
			out.writeObject(this);
			out.close();
			fileOut.close();
		} catch(IOException e) {
			e.printStackTrace();
		}
	}

	public static void writeToFile(String fileName, String toWrite) {
        try {
            // Assume default encoding.
            FileWriter fileWriter = new FileWriter(fileName, true);
            // Always wrap FileWriter in BufferedWriter.
            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
            // Note that write() does not automatically
            // append a newline character.
            bufferedWriter.write(toWrite);
            bufferedWriter.newLine();
            // Always close files.
            bufferedWriter.close();
        } catch(IOException ex) {
            System.out.println("Error writing to file '" + fileName + "'");
        }
    }

	public static void createExperimentFile(String fileName, String dist[], double[] lowT, 
		double[] noiseT, int[] n, int[] m, 
		int[] lowK, double[] noiseK, 
		double[] lowW, double[] noiseW, int numReps) {
		try {
            // Assume default encoding.
            FileWriter fileWriter = new FileWriter(fileName, true);
            // Always wrap FileWriter in BufferedWriter.
            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
            // Note that write() does not automatically
            // append a newline character.

            int numConfigs = dist.length * lowT.length * noiseT.length * n.length * m.length
            	* lowK.length * noiseK.length * lowW.length * noiseW.length;

            bufferedWriter.write(numConfigs + "");
            bufferedWriter.newLine();
            bufferedWriter.write(numReps + "");
            bufferedWriter.newLine();
        
			for (int a = 0; a < dist.length; a++) {
				for (int b = 0; b < lowT.length; b++) {
					for (int c = 0; c < noiseT.length; c++) {
						for (int d = 0; d < n.length; d++) {
							for (int e = 0; e < m.length; e++) {
								for (int f = 0; f < lowK.length; f++) {
									for (int g = 0; g < noiseK.length; g++) {
										for (int h = 0; h < lowW.length; h++) {
											for (int i = 0; i < noiseW.length; i++) {

				if (n[d] > (lowK[f] + 1)) {
					String toWrite = (dist[a] + "," + lowT[b] + "," + noiseT[c] + "," + n[d] + ","
						+ m[e] + "," + lowK[f] + "," + noiseK[g] + "," + lowW[h] + "," + noiseW[i]);
					bufferedWriter.write(toWrite);
	            	bufferedWriter.newLine();
	            }

											}
										}
									}
								}
							}
						}
					}
				}
			}
			bufferedWriter.close();
		} catch(IOException ex) { 
			System.out.println("Error writing to file '" + fileName + "'"); 
		}
    }
}
