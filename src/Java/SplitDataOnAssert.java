import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;


/**
 * Alternative method for checking bugginess vs asserts (Does the assert appear after bugs or before them?)
 * @author caseycas
 *
 */
public class SplitDataOnAssert {
	

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
	
	public static final int THRESHOLD = 1000;
	
	//The file extensions in the original study, we added .ic and .h files later.
	public static Set<String> oldLanguages = new HashSet<String>(Arrays.asList("c", "cc", "cpp", "c++", "cp", "cxx"));


	public static String cleanName(String Name)
	{
		return Name.replace(",", ";").replace("\"", ""); //To help later csv files
	}

	
	public static void main(String[] args)
	{
		//Step outline:
		//1. Get sizes of commits (we will ignore those above a threshold)
		//2. Maintain list of method where assert has been seen
		//3. If method is in this list, put all future data in another marker
		//4. If method is not, put in no assert lists.
		
		try
		{
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/baishakhi", "ccasal", "casey123");
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			
			//1.
			System.out.println("Getting commit size data."); //Weird things can happen in big commits, I want to be able to ignore them
			//Used 4000 + lines as cutoff for total aggregate changes to method, so maybe use 4000 per commit?
			HashMap<String, Integer> commitSize = new HashMap<String, Integer>();
			String query = "select SHA, total_add from assert_july_2015_no_merge1.change_summary_size";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			while(results.next())
			{
				String sha = results.getString(1);
				Integer size = results.getInt(2);
				commitSize.put(sha, size);
			}
			
			System.out.println("Getting method data.");
			
			//Key used "<project>,<file_name>,<method_name>"
			HashMap<String, Integer[]> beforeAssert = new HashMap<String, Integer[]>();
			HashMap<String, Integer[]> afterAssert =  new HashMap<String, Integer[]>();
			HashSet<String> assertHasBeenAdded = new HashSet<String>(); //List of methods which had had an assert added in their lifetime.
			//Key is "<project>,<file_name>,<method_name>,<author_name>" where author name has been run
			//through cleanAuthorName
			HashSet<String> hasCommitted = new HashSet<String>();
			
			
			
			query = "select * from assert_july_2015_no_merge1.fc_everything_src_agg_fixed ORDER BY commit_date WHERE commit_date < \'2014-07-20;\'"; 
			pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			results = pst.executeQuery();
			int count = 0;
			
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
				Integer tot_add = results.getInt(TOTAL_ADD);
				Boolean is_bug = results.getBoolean(IS_BUG);
				String key1 = project + "," + file + "," + method;
				String key2 = key1 + "," + author;
				Integer[] methodStats = null;
				
				if(!oldLanguages.contains(language)) //Skip .h and .ic files
				{
					continue;
				}
				
				if(commitSize.get(sha) > THRESHOLD)
				{
					continue; //Then don't add to the size capped list.
				}
				
				//Check if this method has had an assert added before
				if(assertHasBeenAdded.contains(key1))
				{
					//If yes, update the after data
				}
				else
				{
					//Is this commit adding an assert?
					
					//Is this commit a bugfix?
					
					//If no, update the before data.
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
