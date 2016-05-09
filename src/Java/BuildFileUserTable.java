import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;


public class BuildFileUserTable {

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
			HashMap<String, FileUser> csvLines = new HashMap<String, FileUser>();
			HashMap<String, Integer> userCommits = new HashMap<String, Integer>();
			HashMap<String, Integer> fileCommits = new HashMap<String, Integer>();
			HashSet<String> shaFilePairs = new HashSet<String>();

			while(results.next())
			{
				String project = results.getString(PROJECT);
				String sha = results.getString(SHA);
				String file = results.getString(FILENAME);
				int assertion_add = results.getInt(ASSERTION_ADD);
				int assertion_del = results.getInt(ASSERTION_DEL);
				String author = cleanAuthorName(results.getString(AUTHOR));
				boolean testFlag = results.getBoolean(IS_TEST);
				int lines_add = results.getInt(TOTAL_ADD);
				int lines_del = results.getInt(TOTAL_DEL);
				String key = file + author;
				String keyPair = sha + file; //Have we seen this file commit before.
				FileUser next = null;
				//count++;

				//If this is a new commit, add an commit count to the author.
				if(!shas.contains(sha))
				{
					if(userCommits.containsKey(author))
					{
						int cCount = userCommits.get(author);
						userCommits.put(author, cCount+1);
					}
					else
					{
						userCommits.put(author, 1);
					}
					shas.add(sha);
				}

				if(!shaFilePairs.contains(keyPair))
				{
					shaFilePairs.add(keyPair);
					//Then if we haven't seen this file commit before, increase the 
					//counts of commits to this file by 1.
					if(fileCommits.containsKey(file))
					{
						int fCount = fileCommits.get(file);
						fileCommits.put(file, fCount+1);
					}
					else
					{
						fileCommits.put(file, 1);
					}
				}

				//Either find an object for this file-user pair or create a new one.
				if(csvLines.containsKey(key))
				{
					next = csvLines.get(key);
				}
				else
				{
					next = new FileUser(project, file, author, testFlag);
				}

				next.addUserCommit(assertion_add, assertion_del, lines_add, lines_del, sha);
				csvLines.put(key, next);
			}

			//Write to File and calculate ownership
			PrintWriter writer = new PrintWriter("FileUserAssertInfo.csv");
			writer.println("Project,Filename,Author,Commits,Test,Ownership,Asserts Added, Asserts Removed,Total Added,Total Removed,Author Total Commits, Total File Commits");
			for(FileUser nextLine : csvLines.values())
			{
				int totalCommits = fileCommits.get(nextLine.name);
				nextLine.fileCommitCount = totalCommits;
				int userTotal = userCommits.get(nextLine.user);

				writer.println(nextLine.toString() + "," + userTotal + "," + totalCommits);
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
