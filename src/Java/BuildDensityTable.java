import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;

public class BuildDensityTable {
	public static final int FETCH_SIZE = 100000; //100000 rows at a time.
	//The locations of each column in the table
	public static final int PROJECT = 1;
	public static final int FILENAME = 2;
	public static final int ASSERT_COUNT = 3;
	public static final int LOC = 4;


	public static void main(String args[])
	{
		try
		{
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/baishakhi", "ccasal", "casey123");
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			String query = "select * from assert.asserts_per_file";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			int count = 0;

			//Only keep projects with at least 1 assert in them.
			HashSet<String> haveAsserts = new HashSet<String>();
			while(results.next())
			{
				String project = results.getString(PROJECT);
				String file = results.getString(FILENAME);
				int loc = results.getInt(LOC);
				int assert_count = results.getInt(ASSERT_COUNT);
				count++;
				if(assert_count > 0)
				{
					haveAsserts.add(project);
				}
			}
			
			//Reread the table and copy it into a csv file.
			pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			results = pst.executeQuery();
			PrintWriter writer = new PrintWriter("asserts_per_file.csv");
			writer.println("Project,File,assert_count,loc");
			while(results.next())
			{
				String project = results.getString(PROJECT);
				String file = results.getString(FILENAME).substring(1); //remove leading /
				int loc = results.getInt(LOC);
				int assert_count = results.getInt(ASSERT_COUNT);
				count++;
				if(haveAsserts.contains(project))
				{
					writer.println(project + "," + file + "," + assert_count + "," + loc);
				}
			}
			writer.close();

		}
		catch(SQLException e)
		{
			e.printStackTrace();
			System.exit(-1);
		} 
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}

