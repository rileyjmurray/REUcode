
import java.util.Arrays;

public class RunBadRatioFinder {
	public static void main(String[] args) {

		double[][] testP = {{0.3333, 0.3333, 0.0},{1.0, 0.6667, 0.6667},{0.3333, 0.0, 0.3333}};
		int[] testServers = {2,1,1};
		double[] testSol = {0.3333, 1.0, 0.6667};
		BadRatioFinder brf = new BadRatioFinder(testP, testServers, testSol);
		brf.computeLPCoefficients();
		brf.constructAndSolveLP();

		System.out.println();
		System.out.println("Maximizing weights");
		System.out.println(Arrays.toString(brf.getW()));
		System.out.println();
		System.out.println("maximal Delta");
		System.out.println(brf.getDelta());
		System.out.println();
	}
}