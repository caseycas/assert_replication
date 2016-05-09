import java.util.HashSet;
import java.util.Set;


public class FileUser {
	public String project;
	public String name;
	public String user;
	public int userFileCommitCount;
	public int fileCommitCount; //Ended up setting this manually as there was no good place to do this incrementally.
	public int assertsAdded;
	public int assertsRemoved;
	public int linesAdded;
	public int linesRemoved;
	public boolean isTest;
	Set<String> shas;

	public FileUser(String project, String name, String user, boolean testFlag)
	{
		this.project = project;
		this.name = name;
		this.user = user;
		isTest = testFlag;
		userFileCommitCount = 0;
		fileCommitCount = 0;
		assertsAdded = 0;
		assertsRemoved = 0;
		linesAdded = 0;
		linesRemoved = 0;
		shas = new HashSet<String>();
	}


	public boolean addUserCommit(int assert_add, int assert_del, int total_add, int total_del, String sha)
	{
		assertsAdded += assert_add;
		assertsRemoved += assert_del;
		linesAdded += total_add;
		linesRemoved += total_del;
		if(!shas.contains(sha))
		{
			shas.add(sha);
			userFileCommitCount++;
		}
		return true;
	}

	public double getOwnership()
	{
		return (double) userFileCommitCount/ (double) fileCommitCount;
	}

	public String toString()
	{
		double ownership = getOwnership();
		return project + "," + name + "," + user + "," + userFileCommitCount + "," + isTest + "," + ownership +  "," + assertsAdded + "," + assertsRemoved + "," + linesAdded + "," + linesRemoved;
	}

}
