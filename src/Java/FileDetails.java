import java.sql.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashSet;
import java.util.Set;


public class FileDetails {
public String project;
public String name;
public Set<String> committers;
public int assertsAdded;
public int assertsRemoved;
public int linesAdded;
public int linesRemoved;
public int commitCount;
public boolean isTest;
public Date firstDate;

public FileDetails (String p, String n, boolean t, Date first)
{
	project = p;
	name = n;
	isTest = t;
	firstDate = first; //First recorded commit to this file.
	committers = new HashSet<String>();
	assertsAdded = 0;
	assertsRemoved = 0;
	linesAdded = 0;
	linesRemoved = 0;
	commitCount = 0;
}
	
public boolean addCommit(String author, int assert_add, int assert_del, int total_add, int total_del, Date commitDate)
{
	
	//I don't trust that the prepared statements are ordering the dates correctly, so I'll look for the min myself:
	if(firstDate.compareTo(commitDate) > 0)
	{
		firstDate = commitDate;
	}
	
	if(!author.trim().equals("")) //Ignore blank authors
	{
		committers.add(author);
	}
	assertsAdded += assert_add;
	assertsRemoved += assert_del;
	linesAdded += total_add;
	linesRemoved += total_del;
	commitCount++;

	return true;
}

public void updateAsserts(int assert_add, int assert_del, int total_add, int total_del)
{
	assertsAdded += assert_add;
	assertsRemoved += assert_del;
	linesAdded += total_add;
	linesRemoved += total_del;
}

/**
 * Get the age of this file in days.
 * @return
 */
public long getAge()
{
	Calendar temp = Calendar.getInstance();
	long millesecondDiff = temp.getTime().getTime() - firstDate.getTime();
	long diffDays = millesecondDiff / (24 * 60 * 60 * 1000);
	return diffDays;	
}

public String toString()
{
	return project + "," + name + "," + committers.size() + "," + assertsAdded + "," + assertsRemoved +  "," + linesAdded + "," + linesRemoved + "," + isTest + "," + commitCount + "," + getAge();
}

	
}
