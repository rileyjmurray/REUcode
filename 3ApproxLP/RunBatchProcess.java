
import gurobi.*;

public class RunBatchProcess {
	public static void main(String[] args) throws GRBException {
		String[] dist = {"default"};
		double[] lowT = {5.0};
		double[] noiseT = {5.0};
		int[] n = {20, 40};
		int[] m = {5, 40};
		int[] lowK = {1,3};
		double[] noiseK = {10.0,20.0};
		double[] lowW = {5.0};
		double[] noiseW = {10.0};
		int numReps = 10;

		BatchProcess.createExperimentFile("test1_rs1", dist, lowT,
			noiseT, n, m, lowK, noiseK,
			lowW, noiseW, numReps);
		BatchProcess p = new BatchProcess("test1_rs1", 1);
		/*public static void createExperimentFile(String fileName, String dist[], double[] lowT, 
		double[] noiseT, int[] n, int[] m, 
		int[] lowK, double[] noiseK, 
		double[] lowW, double[] noiseW, int numReps) {*/
	}
}