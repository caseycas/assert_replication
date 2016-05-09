import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;


public class SelectBugSample {
	public static final int FETCH_SIZE = 100000; //100000 rows at a time.
	//The locations of each column in the table
	public static final int PROJECT = 1;
	public static final int SHA = 2;
	public static final int LANGUAGE = 3;
	public static final int FILENAME = 4;
	public static final int IS_TEST = 5;
	public static final int METHOD_NAME = 6;
	public static final int ASSERTION_ADD=7;
	public static final int ASSERTION_DEL=8;
	public static final int TOTAL_ADD=9;
	public static final int TOTAL_DEL=10;
	public static final int IS_BUG=11;
	
	public static void main(String args[])
	{
		try
		{
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/baishakhi", "ccasal", "casey123");
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			String query = "select * from assertion.fc_everything WHERE assertion_add > assertion_del AND is_bug=1 AND project=\'mysql\' AND total_add < 100";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			int count = 0;
			
			HashMap<String, Integer> projects = new HashMap<String, Integer>();
			HashSet<String> shas = new HashSet<String>();
			HashSet<String> files = new HashSet<String>();
			ArrayList<String> output = new ArrayList<String>();
			
			while(results.next() && count < 50)
			{
				System.out.println("Ding.");
				String project = results.getString(PROJECT);
				String sha = results.getString(SHA);
				String file = results.getString(FILENAME);
				String language = results.getString(LANGUAGE);
				String assertion_add = results.getString(ASSERTION_ADD);
				String assertion_del = results.getString(ASSERTION_DEL);
				//Criteria: we can't see files from the same commit and we won't
				//sample from the same project more than 50 times.
				if(!projects.containsKey(project) || (projects.containsKey(project) && projects.get(project) < 50))
				{
					if(!(shas.contains(sha)) && !(files.contains(file)))
					{
						if(projects.containsKey(project))
						{
							projects.put(project, projects.get(project) + 1);
						}
						else
						{
							projects.put(project, 1);
						}
						shas.add(sha);
						files.add(file);
						output.add(language + ": " + project + " " +  sha + " " + file + " " + assertion_add + " " + assertion_del);
						count++;
					}
				}
			}
			
			//Print cpp files
			for(String next : output)
			{
				if(next.startsWith("cpp:"))
				{
					System.out.println(next);
				}
			}
			
			//Print c files
			for(String next : output)
			{
				if(next.startsWith("c:"))
				{
					System.out.println(next);
				}
			}

		}
		catch(SQLException e)
		{
			e.printStackTrace();
			System.exit(-1);
		} 
		/*catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
	}

}
