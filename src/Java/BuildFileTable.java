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


public class BuildFileTable {

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
	public static final int MINYEAR = 1990; //I say this is probably an okay cut off for valid dates.
	public static final int MAXYEAR = 2014; //No commits from the future either.
	
	public static String cleanAuthorName(String authorName)
	{
		return authorName.replace(",", ";").replace("\"", ""); //To help later csv files
	}
	
	public static void main(String args[])
	{
		try
		{
			Connection githubDB = null;
			githubDB = DriverManager.getConnection("jdbc:postgresql://godot.cs.ucdavis.edu:5432/baishakhi", "ccasal", "casey123");
			githubDB.setAutoCommit(false);

			System.out.println("Connected to Database.");
			String query = "select * from assert.fc_everything";
			PreparedStatement pst = githubDB.prepareStatement(query);
			pst.setFetchSize(FETCH_SIZE);
			ResultSet results = pst.executeQuery();
			int count = 0;
			
			HashSet<String> shas = new HashSet<String>();
			HashMap<String, FileDetails> csvLines = new HashMap<String, FileDetails>();

			while(results.next())
			{
				//NOTE: I'm not seeing the 1991 or 1970 commits first. Why?
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
				
				
				String project = results.getString(PROJECT);
				String sha = results.getString(SHA);
				String file = results.getString(FILENAME);
				int assertion_add = results.getInt(ASSERTION_ADD);
				int assertion_del = results.getInt(ASSERTION_DEL);
				int total_add = results.getInt(TOTAL_ADD);
				int total_del = results.getInt(TOTAL_DEL);
				boolean isTest = results.getBoolean(IS_TEST);
				String author = cleanAuthorName(results.getString(AUTHOR));
				FileDetails next = null;
				count++;
				
				//Commit Count is not working correctly.
				
				if(shas.contains(sha))
				{
					if(csvLines.containsKey(file))
					{
						next = csvLines.get(file);
					}
					else
					{
						next = new FileDetails(project, file, isTest, commitDate);
					}
					next.updateAsserts(assertion_add, assertion_del, total_add, total_del);
				}
				else
				{
					if(csvLines.containsKey(file))
					{
						next = csvLines.get(file);
					}
					else
					{
						next = new FileDetails(project, file, isTest, commitDate);
					}
					
					next.addCommit(author, assertion_add, assertion_del, total_add, total_del, commitDate);
					csvLines.put(file, next);
				}

			}
			
			HashMap<String, Integer> assertInstances = new HashMap<String,Integer>();
			HashMap<String, Integer> allInstances = new HashMap<String,Integer>();
			
			//Write to File:
			PrintWriter writer = new PrintWriter("FileAssertInfo.csv");
			writer.println("Project,File,Committer Count,Asserts Added,Asserts Deleted,Lines Added,Lines Deleted,Test,Commit Count,File Age");
			for(FileDetails nextLine : csvLines.values())
			{
				String projectName = nextLine.project;
				Integer assertsUsed = nextLine.assertsAdded;
				//This is to see if projects are being unfairly represented.
				if(allInstances.containsKey(projectName))
				{
					count = allInstances.get(projectName);
					allInstances.put(projectName, count + 1);
				}
				else
				{
					allInstances.put(projectName, 1);
				}
				if(assertsUsed > 0)
				{
					if (assertInstances.containsKey(projectName))
					{
						count = assertInstances.get(projectName);
						assertInstances.put(projectName, count + 1);
					}
					else
					{
						assertInstances.put(projectName, 1);
					}
				}
				writer.println(nextLine.toString());
			}
			writer.close();
			
			/*
			System.out.println("Count of all project instances");
			for(String p : allInstances.keySet())
			{
				System.out.println(p + ":" +allInstances.get(p));
			}
			
			System.out.println("Count of assert project instances");
			for(String p : assertInstances.keySet())
			{
				System.out.println(p + ":" + assertInstances.get(p));
			}
			*/
			
			double totalCount = 0;
			double totalAssertCount = 0;
			
			System.out.println("Relative values:");
			for(String p : allInstances.keySet())
			{
				totalCount += (double) allInstances.get(p);
				totalAssertCount += (double) assertInstances.get(p);
			}
			System.out.println(totalCount);
			System.out.println(totalAssertCount);
			
			for(String p : allInstances.keySet())
			{
				double allRel = ((double)allInstances.get(p))/totalCount;
				double assertRel =((double)assertInstances.get(p))/totalAssertCount;
				System.out.println(p + ","  + allRel + "," + assertRel + "," + ((double)allInstances.get(p)) + "," + ((double)assertInstances.get(p)));
			}
			
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
