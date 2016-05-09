import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;


public class BuildMethodUserTable {

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
	public static final int AUTHOR=12;

	//The file extensions in the original study, we added .ic and .h files later.
	public static Set<String> oldLanguages = new HashSet<String>(Arrays.asList("c", "cc", "cpp", "c++", "cp", "cxx"));
	
	public static String cleanName(String Name)
	{
		return Name.replace(",", ";").replace("\"", ""); //To help later csv files
	}

	/**
	 * Some of things here are not normal methods.  Remove anything with
	 * NA or that has more than 1 word in it
	 * @param methodName
	 * @return
	 */
	public static boolean normalMethodName(String methodName)
	{
		String tmp = methodName.trim();
		if(tmp.equalsIgnoreCase("NA"))
		{
			return false;
		}
		else if(tmp.contains(","))
		{
			return false;
		}
		else if(tmp.split(" ").length != 1)
		{
			return false;
		}
		else
		{
			return true;
		}

	}

	public static void main(String args[])
	{
		try
		{
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/ccasal", "ccasal", "casey123");
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			//String query = "select * from assert_3rd_sep.fc_everything_src_method";
			//String query = "select * from assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE commit_date < \'2014-07-20\'"; //New table
			String query = "select * from assert_replication.fc_everything_src_agg WHERE commit_date < \'2014-07-20\'"; //New table
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			int count = 0;

			HashMap<String, MethodAssert> csvLines = new HashMap<String, MethodAssert>();

			while(results.next())// && count < 200)
			{
				count++;
				String project = results.getString(PROJECT);
				String sha = results.getString(SHA);
				String file = cleanName(results.getString(FILENAME));
				String method = cleanName(results.getString(METHOD_NAME));
				//System.out.println(project + " " + file + " " + method);
				String language = results.getString(LANGUAGE);
				if(!normalMethodName(method))
				{
					System.out.println(method);
					System.out.println("Skipping..");
					continue; //Skip things marked as methods that aren't
				}
				if(!oldLanguages.contains(language)) //Skip .h and .ic files for now.
				{
					continue;
				}
				int assertion_add = results.getInt(ASSERTION_ADD);
				int assertion_del = results.getInt(ASSERTION_DEL);
				String author = cleanName(results.getString(AUTHOR));
				if(author.trim().equals(""))
				{
					continue; //Skip unauthored commits
				}
				boolean testFlag = results.getBoolean(IS_TEST);
				int lines_add = results.getInt(TOTAL_ADD);
				int lines_del = results.getInt(TOTAL_DEL);
				String key = project + file + method; //Have we seen this method before?
				MethodAssert next = null;
				//count++;

				if(csvLines.containsKey(key))
				{
					next = csvLines.get(key);
				}
				else
				{
					next = new MethodAssert(project, file, method, testFlag);
				}
				next.addNewContribution(author, assertion_add, assertion_del, lines_add, lines_del, sha);
				csvLines.put(key, next);
			}

			//Write to File for Q1 (simplified version of Q2 table)
			PrintWriter writer = new PrintWriter("MethodAssertInfoNoMerge.csv");
			writer.println("Project,Filename,Method,Test,Asserts Added,Asserts Removed,Total Added,Total Removed,Committer Count,Total Method Commits");
			for(MethodAssert nextMethod : csvLines.values())
			{
				writer.println(nextMethod.getOutputForFile());
			}
			writer.close();


			//Write to File for Q2.
			writer = new PrintWriter("MethodUserAssertInfoNoMerge.csv");
			writer.println("Project,Filename,Method,Author,Test,Asserts Added,Asserts Removed,Total Added,Total Removed,Author Total Commits,Committer Count,Total Method Commits");
			for(MethodAssert nextMethod : csvLines.values())
			{
				ArrayList<String> output = nextMethod.getOutputPerUser();
				for(String line : output)
				{
					writer.println(line);
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
