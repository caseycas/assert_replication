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
import java.util.Map;
import java.util.Set;


public class BuildMethodBugTable {


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
	
	public static final int THRESHOLD = 100; //What if cap is 1000?
	
	//The file extensions in the original study, we added .ic and .h files later.
	public static Set<String> oldLanguages = new HashSet<String>(Arrays.asList("c", "cc", "cpp", "c++", "cp", "cxx"));


	public static String cleanName(String Name)
	{
		return Name.replace(",", ";").replace("\"", ""); //To help later csv files
	}

	public static void main(String args[])
	{
		try
		{
			Connection githubDB = null;
			if(args.length < 3)
			{
				System.out.println("Please enter the database name via jdbc, your username, and your password.");
				System.out.println("Example: jdbc:postgresql://godot.cs.ucdavis.edu:5432/ccasal ccasal casey123");
				System.exit(-1);
			}
			//githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/ccasal", "ccasal", "casey123");
			githubDB = DriverManager.getConnection(args[0], args[1], args[2]);
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			
			System.out.println("Getting commit size data."); //Weird things can happen in big commits, I want to be able to ignore them
			//Used 4000 + lines as cutoff for total aggregate changes to method, so maybe use 4000 per commit?
			HashMap<String, Integer> commitSize = new HashMap<String, Integer>();
			//String query = "select SHA, total_add from assert_july_2015_no_merge1.change_summary_size";
			/*String query = "select SHA, total_add from assert_replication.change_summary_size";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			while(results.next())
			{
				String sha = results.getString(1);
				Integer size = results.getInt(2);
				commitSize.put(sha, size);
			}*/
			System.out.println("Getting method data.");
			//query = "select * from assert_july_2015_no_merge1.fc_everything_src_agg_fixed"; 
			//query = "select * from assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE commit_date < \'2014-07-20;\' ORDER BY commit_date";
			String query = "select * from assert_replication.fc_everything_src_agg WHERE commit_date < \'2014-07-20;\' ORDER BY commit_date";
			//query = "select * from assert_july_2015_no_merge1.replication_filtered";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			int count = 0;
			
			//Key used "<project>,<file_name>,<method_name>"
			HashMap<String, Integer[]> allMethods = new HashMap<String, Integer[]>();
			HashMap<String, Integer[]> smallMethods =  new HashMap<String, Integer[]>();
			//Key is "<project>,<file_name>,<method_name>,<author_name>" where author name has been run
			//through cleanAuthorName
			HashSet<String> hasCommittedAll = new HashSet<String>();
			HashSet<String> hasCommittedSmall = new HashSet<String>();
			//True if ignoring initial commits?
			HashSet<String> seenBefore = new HashSet<String>(); //This isn't super precise either, since we have the same day commit problem.
			
			while(results.next())
			{
				String sha = results.getString(SHA);
				String project = results.getString(PROJECT);
				String file = cleanName(results.getString(FILENAME));
				//Clean out methods and author names of commas
				String method = cleanName(results.getString(METHOD_NAME));
				String author = cleanName(results.getString(AUTHOR));
				String language = results.getString(LANGUAGE);
				Integer tot_assert = results.getInt(ASSERTION_ADD);
				Integer assert_del = results.getInt(ASSERTION_DEL);
				Integer tot_add = results.getInt(TOTAL_ADD);
				Integer tot_del = results.getInt(TOTAL_DEL);
				Boolean is_bug = results.getBoolean(IS_BUG);
				String key1 = project + "," + file + "," + method;
				String key2 = key1 + "," + author;
				Integer[] methodStats = null;
				
				//Skip big + initial commits.
				/*if(!seenBefore.contains(key1))
				{
					seenBefore.add(key1); //Remove all initial touches...
					continue;
				}
				
				if(commitSize.get(sha) > THRESHOLD)
				{
					continue; //Then don't add to the size capped list.
				}*/
				
				/*if(method.equals("NA") || method.equals("")) //Skip the NA methods.
				{
					continue;
				}*/
				
				if(!oldLanguages.contains(language)) //Skip .h and .ic files
				{
					continue;
				}
				
				//Get it for everything (no size restraint)
				if(allMethods.containsKey(key1))
				{
					methodStats = allMethods.get(key1);
				}
				else
				{
					methodStats = new Integer[6];
					methodStats[0] = 0; //Asserts added
					methodStats[1] = 0; //Asserts deleted
					methodStats[2] = 0; //Lines added
					methodStats[3] = 0; //Lines deleted
					methodStats[4] = 0; //Bug count
					methodStats[5] = 0; //Dev count
				}
				
				methodStats[0] += tot_assert;
				methodStats[1] += assert_del;
				methodStats[2] += tot_add;
				methodStats[3] += tot_del;
				if(is_bug)
				{
					methodStats[4]++;
				}
				
				if(!hasCommittedAll.contains(key2))
				{
					methodStats[5]++;
					hasCommittedAll.add(key2);
				}
				
				allMethods.put(key1, methodStats);
				/*
				assert(commitSize.containsKey(sha));
				
				if(commitSize.get(sha) > THRESHOLD)
				{
					continue; //Then don't add to the size capped list.
				}
				
				methodStats = null;
				
				//Get it for everything (no size restraint)
				if(smallMethods.containsKey(key1))
				{
					methodStats = smallMethods.get(key1);
				}
				else
				{
					methodStats = new Integer[4];
					methodStats[0] = 0; //Asserts added
					methodStats[1] = 0; //Lines added
					methodStats[2] = 0; //Bug count
					methodStats[3] = 0; //Dev count
				}
				
				methodStats[0] += tot_assert;
				methodStats[1] += tot_add;
				if(is_bug)
				{
					methodStats[2]++;
				}
				
				
				if(!hasCommittedSmall.contains(key2))
				{
					methodStats[3]++;
					hasCommittedSmall.add(key2);
				}
				smallMethods.put(key1, methodStats);
				*/
			}
			
			//PrintWriter everything = new PrintWriter("method_assert_old_filtered.csv");
			PrintWriter everything = new PrintWriter("method_assert_everything_before_ICSE_no_merge_expanded.csv");
			//PrintWriter sizeCapped = new PrintWriter("method_assert_no_initial_before_ICSE_no_merge.csv");
			
			//OLD ones don't contain information on added and deleted.
			everything.write("project,file_name,method_name,assert_add,assert_del,total_add,total_del,total_bug,dev\n");
			//sizeCapped.write("project,file_name,method_name,total_assert,total_add,total_bug,dev\n");
			
			System.out.println(allMethods.size());
			System.out.println(smallMethods.size());
			
			for(Map.Entry<String, Integer[]> nextLine : allMethods.entrySet())
			{
				everything.write(nextLine.getKey() + "," + Utilities.ArrayAsCsv(nextLine.getValue()) + "\n");
			}
			/*
			for(Map.Entry<String, Integer[]> nextLine : smallMethods.entrySet())
			{
				//System.out.println(nextLine.getKey() + "," + Utilities.ArrayAsCsv(nextLine.getValue()));
				sizeCapped.write(nextLine.getKey() + "," + Utilities.ArrayAsCsv(nextLine.getValue()) + "\n");
			}
			*/
			
			everything.close();
			//sizeCapped.close();
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

