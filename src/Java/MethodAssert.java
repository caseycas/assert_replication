import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;


public class MethodAssert {
	public String project;
	public String file;
	public String method;
	public boolean isTest;
	public HashSet<String> shas;
	public HashMap<String, Contribution> contributors; //Map authors to their contributions

	public MethodAssert(String p, String f, String m, boolean t)
	{
		project = p;
		file = f;
		method = m;
		isTest = t;
		shas = new HashSet<String>();
		contributors = new HashMap<String, Contribution>();
	}

	public int getCommitterCount()
	{
		return contributors.keySet().size();
	}

	public int getTotalCommits()
	{
		int count = 0;
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			count += dev.getValue().commits;
		}
		if(count != shas.size())
		{
			System.out.println("Commit miscount:");
			System.out.println(count);
			System.out.println(shas.size());
			System.exit(-1);
		}
		return count;
	}

	public int getTotalAssertsAdd()
	{
		int count = 0;
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			count += dev.getValue().total_asserts_add;
		}
		return count;
	}

	public int getTotalAssertsDel()
	{
		int count = 0;
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			count += dev.getValue().total_asserts_del;
		}
		return count;
	}

	public int getTotalLinesAdd()
	{
		int count = 0;
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			count += dev.getValue().total_lines_add;
		}
		return count;
	}

	public int getTotalLinesDel()
	{
		int count = 0;
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			count += dev.getValue().total_lines_del;
		}
		return count;
	}

	public void addNewContribution(String dev, int assertAdd, int assertDel, int lineAdd, int lineDel, String sha)
	{
		Contribution tmp = null;

		//See if this author has contributed to this method before.
		if(contributors.containsKey(dev))
		{
			tmp = contributors.get(dev);
		}
		else
		{
			tmp = new Contribution();
		}
		//Track if this is a new commit.
		if(!shas.contains(sha))
		{
			shas.add(sha);
			tmp.commits++;
		}
		tmp.total_asserts_add += assertAdd;
		tmp.total_asserts_del += assertDel;
		tmp.total_lines_add += lineAdd;
		tmp.total_lines_del += lineDel;
		contributors.put(dev, tmp);
	}

	public ArrayList<String> getOutputPerUser()
	{
		ArrayList<String> output = new ArrayList<String>();
		for(Map.Entry<String, Contribution> dev : contributors.entrySet())
		{
			output.add(project + "," + file + "," + method + "," + dev.getKey() + "," + isTest + "," + dev.getValue().total_asserts_add + "," + dev.getValue().total_asserts_del + "," + dev.getValue().total_lines_add + "," + dev.getValue().total_lines_del + "," + dev.getValue().commits + "," + getCommitterCount() + "," + getTotalCommits()); 
		}
		return output;
	}

	public String getOutputForFile()
	{
		return project + "," + file + "," + method + "," + isTest + "," + getTotalAssertsAdd() + "," + getTotalAssertsDel() + "," + getTotalLinesAdd() + "," + getTotalAssertsDel() + "," + getCommitterCount() +  "," + getTotalCommits(); 
	}
}
