
import java.util.PriorityQueue;

public class DataCenter {

	public PriorityQueue<Server> servers;

	public DataCenter(int numSvr) {
		servers = new PriorityQueue<Server>(numSvr);
		for (int i = 0; i < numSvr; i ++) {
			servers.add(new Server(i));
		}
	}

	public double scheduleJobOnMinServer(int j, double t) {
		// return the time at which this job completes.

		// don't no need to store the job for now
		Server s = servers.poll();
		s.nextFree = s.nextFree + t;
		servers.add(s);
		return s.nextFree;
	}

	public class Server implements Comparable {
		public double nextFree;
		public int id;

		public Server(int inID) {
			nextFree = 0;
			id = inID;
		}

		public int compareTo(Object o) {
			if (o instanceof Server) {
				Server s = (Server) o;
				if (s.nextFree < this.nextFree) {
					return 1; // then we have lower priority
				} else if (s.nextFree > this.nextFree) {
					return -1;
				} else {
					return 0;
				}
			} else {
				return -1;
			}
		}
	}
}