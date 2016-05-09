import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;


public class BuildExperienceTable {

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
	public static final int DATE=13;
	//public static final int PROJECTEXP = 14;
	//public static final int FILEEXP = 15;
	public static final int MINYEAR = 1990; //I say this is probably an okay cut off for valid dates.
	public static final int MAXYEAR = 2014; //No commits from the future either.
	
	public static final int THRESHOLD = 500; //What if cap is 1000?
	
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
			HashMap<String, Integer> generalExperience = new HashMap<String, Integer>();
			HashMap<String, Integer> specificExperience = new HashMap<String, Integer>();
			HashMap<String, Integer> methodExperience = new HashMap<String, Integer>();
			HashSet<String> shas = new HashSet<String>();
			HashSet<String> fileCommits = new HashSet<String>();
			HashSet<String> methodCommits = new HashSet<String>();
			HashSet<String> hasAsserts = new HashSet<String>(); //According to method in paper, only look at methods with asserts?
			HashMap<String, Integer> commitCount = new HashMap<String, Integer>(); //Key is project,file,method, stored value is the number of commits to this region (so we could ignore initial commits, for instance...)
			//HashMap<String, Double[]> expMedians = new HashMap<String,Double[]>(); //Map of median method, file, and project experience for asserts + no asserts.
			HashMap<String, Integer> commitSize = new HashMap<String, Integer>();
			
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/baishakhi", "ccasal", "casey123");
			githubDB.setAutoCommit(false);
			System.out.println("Connected to Database.");
			
			System.out.println("Getting commit size data."); //Weird things can happen in big commits, I want to be able to ignore them
			//Used 4000 + lines as cutoff for total aggregate changes to method, so maybe use 4000 per commit?

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

			query = "select * from assert_july_2015_no_merge1.fc_everything_src_agg_fixed WHERE commit_date < \'2014-7-20\' order by commit_date";
			pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			results = pst.executeQuery();
			int count = 0;
			
		
			//Write to File:
			PrintWriter writer = new PrintWriter("MethodExperienceTable.csv");
			writer.println("Project,File,Method,Author,Sha,Asserts Added,Asserts Deleted,Lines Added,Lines Deleted,Test,Method Experience,File Experience,Project Experience,Total Commits");

			while(results.next()) // && count < 500)
			{
				count++;
				//NOTE: I'm not seeing the 1991 or 1970 commits first. Seems to be correct now.
				Date commitDate = results.getDate(DATE);
				//Toss out entry if its too early or too late:
				Calendar calendar = new GregorianCalendar();
				calendar.setTime(commitDate);
				//System.out.println(commitDate);
				if(calendar.get(Calendar.YEAR) < MINYEAR || calendar.get(Calendar.YEAR) > MAXYEAR)
				{
					//System.out.println(commitDate);
					continue;
				}
				
				String author = cleanName(results.getString(AUTHOR));
				//System.out.println(author);
				if(author.trim().equals("")) //Ignore blank authors
				{
					continue;
				}
				
				String project = results.getString(PROJECT);
				String sha = results.getString(SHA);
				String file = cleanName(results.getString(FILENAME));
				String method = cleanName(results.getString(METHOD_NAME));
				String language = results.getString(LANGUAGE);
				String key = project + "," + file + "," + method;
				
				/*if(commitSize.get(sha) > THRESHOLD)
				{
					continue; //Then don't add to the size capped list.
				}*/
				
				//TODO: Add method cleaning HERE:
				//System.out.println(method);
				if(!normalMethodName(method))
				{
					//System.out.println("Skipping..");
					continue; //Skip things marked as methods that aren't
				}
				if(!oldLanguages.contains(language)) //Skip .h and .ic files for now.
				{
					continue;
				}
				
				int assertion_add = results.getInt(ASSERTION_ADD);
				int assertion_del = results.getInt(ASSERTION_DEL);
				int total_add = results.getInt(TOTAL_ADD);
				int total_del = results.getInt(TOTAL_DEL);
				boolean isTest = results.getBoolean(IS_TEST);
				
				if(commitCount.containsKey(key))
				{
					Integer oldCount = commitCount.get(key);
					commitCount.put(key, oldCount+1);
				}
				else
				{
					commitCount.put(key,1);
				}
				
				if(assertion_add > 0 || assertion_del > 0)
				{
					hasAsserts.add(project + "," + file + "," + method);
				}
				
				String methodKey = author+project+file+method;
				String specificKey = author+project+file;
				String generalKey = author+project;
				
				if(!shas.contains(sha))
				{
					if(generalExperience.containsKey(generalKey))
					{
						Integer temp = generalExperience.get(generalKey);
						generalExperience.put(generalKey, temp +1);
					}
					else
					{
						generalExperience.put(generalKey, 1);
					}
					shas.add(sha);
				}
				
				if(!fileCommits.contains(sha+file))
				{
					if(specificExperience.containsKey(specificKey))
					{
						Integer temp = specificExperience.get(specificKey);
						specificExperience.put(specificKey, temp +1);
					}
					else
					{
						specificExperience.put(specificKey, 1);
					}
					fileCommits.add(sha+file);
				}
				
				if(!methodCommits.contains(sha+file+method))
				{
					if(methodExperience.containsKey(methodKey))
					{
						Integer temp = methodExperience.get(methodKey);
						methodExperience.put(methodKey, temp +1);
					}
					else
					{
						methodExperience.put(methodKey, 1);
					}
					methodCommits.add(sha+file+method);
				}
				
				Integer sExp = specificExperience.get(specificKey);
				Integer gExp = generalExperience.get(generalKey);
				Integer mExp = methodExperience.get(methodKey);
				
				writer.println(project + "," + file + "," + method + "," + author + "," + sha + "," + assertion_add + "," + assertion_del + "," + total_add + "," + total_del + "," + isTest + "," + mExp + "," + sExp + "," + gExp + "," + commitCount.get(key));
			}
			
			writer.close();
			
			writer = new PrintWriter("MethodExperienceTableAssertFuncOnlyNoMerge.csv");
			Scanner sc = new Scanner(new File("MethodExperienceTable.csv"));
			writer.println("Project,File,Method,Author,Sha,AssertsAdded,AssertsDeleted,LinesAdded,LinesDeleted,Test,MethodExperience,FileExperience,ProjectExperience,TotalCommits");
			
			while(sc.hasNextLine())
			{
				String nextLine = sc.nextLine();
				//System.out.println(nextLine);
				String pieces[] = nextLine.split(",");
				String key = pieces[0] + "," + pieces[1] + "," + pieces[2];
				if(hasAsserts.contains(key)) //Ignore methods without any asserts.
				{
					writer.println(nextLine);
				}
			}
			
			//writer.println("Project,File,Method,Method.Assert.Exp,Method.No.Assert.Exp, File.Assert.Exp, File.No.Assert.Exp, Project.Assert.Exp, Project.No.Assert.Exp");
			
			sc.close();
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
