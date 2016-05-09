import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;


public class MethodSize {

	public static final int NAME = 0;
	public static final int FILE = 1;
	public static final int LINE = 2;
	public static final int KIND = 3;
	public static final int LINENUM = 4;
	public static final int FILEDIVIDEPOINT = 34;
	public static final int LOCDIVIDEPOINT = 5;

	public static void main(String args[])
	{
		Scanner sc;
		try {
			HashMap<String, Integer> fileSizes = new HashMap<String, Integer>();
			sc = new Scanner(new File("file_size.txt"));
			//Get the file sizes.
			//Skip header
			sc.nextLine();
			while(sc.hasNextLine())
			{
				String line = sc.nextLine();
				String[] tmp = line.split(",");
				if(tmp.length == 2) //Ignore header/irregular lines.
				{
				fileSizes.put(tmp[0].substring(FILEDIVIDEPOINT), Integer.parseInt(tmp[1]));
				}
			}
			sc.close();
			
			sc = new Scanner(new File("tags"));

			HashMap<String, HashMap<String, Integer>> fileRep = new HashMap<String, HashMap<String, Integer>>();
			int count = 0;
			HashMap<String, Integer> sampleFile = null;
			
			HashMap<String, Integer> methodSizes = new HashMap<String, Integer>();

			while(sc.hasNextLine())
			{
				String line = sc.nextLine();
				String[] pieces = line.split("\t");
				if(pieces.length >= 5)
				{
					//Ignore non-c files
					if(!pieces[FILE].endsWith(".c"))
					{
						continue;
					}
					
					//Consider macros/define?, structures, functions, and typedefs
					if(pieces[KIND].equals("d") || pieces[KIND].equals("t") || pieces[KIND].equals("s") || pieces[KIND].equals("f"))
					//if(pieces[KIND].equals("t") || pieces[KIND].equals("s") || pieces[KIND].equals("f"))
					{
						if(fileRep.containsKey(pieces[FILE]))
						{
							sampleFile = fileRep.get(pieces[FILE]);

						}
						else
						{
							sampleFile  = new HashMap<String, Integer>();

						}
						//We add count to uniquely identify each instance.
						sampleFile.put(pieces[KIND] + ";" + pieces[NAME]+ ";" +count, Integer.parseInt(pieces[LINENUM].substring(LOCDIVIDEPOINT)));
						fileRep.put(pieces[FILE], sampleFile);
					}
				}
				count++;
			}
			sc.close();
			//Sort each file by line number 
			for(Map.Entry<String, HashMap<String, Integer>> fileStruct : fileRep.entrySet())
			{

				HashMap<String, Integer> sortedfile = (HashMap<String, Integer>)MapUtils.sortByValue(fileStruct.getValue());
				if(fileStruct.getKey().equals("gcc/gcc/testsuite/gcc.dg/fixed-point/cast-bad.c"))
				{
					System.out.println(fileSizes.get(fileStruct.getKey()));
					for(Map.Entry<String,Integer> location : sortedfile.entrySet())
					{
						System.out.println(location.getKey() + ": " + location.getValue());
					}
					System.exit(0);
				}
				Integer priorLoc = -1;
				String priorName = null;

				String currentName = null;
				Integer currentLoc = -1;

				for(Map.Entry<String,Integer> location : sortedfile.entrySet())
				{
					if(priorLoc == -1)
					{
						priorName = location.getKey();
						priorLoc = location.getValue();
						currentName = location.getKey();
						currentLoc = location.getValue();
					}
					else
					{
						currentName = location.getKey();
						currentLoc = location.getValue();
						//Determine if prior name is a function and remove the excess information.
						String curType = priorName.substring(0,1);
						/*if(fileStruct.getKey().equals("gcc/gcc/config/spu/spu.c"))
						{
							System.out.println("Prior: " + priorName + ": " + priorLoc);
							System.out.println("Current: " + currentName + ": " + currentLoc);
						}*/
						if(curType.equals("f"))
						{
							String actualName = priorName.split(";")[1];
							//System.out.println(fileStruct.getKey() + ": " + currentLoc);
							int methodsize = currentLoc-priorLoc;
							if(methodsize == 0) //In lined functions should still be at least one.
								methodsize++;
							methodSizes.put(fileStruct.getKey() + "," + actualName, methodsize);
						}
						priorName = currentName;
						priorLoc = currentLoc;
					}
				}
				//Calculate the size of the last method
				String curType = currentName.substring(0,1);
				if(curType.equals("f"))
				{
					String actualName = currentName.split(";")[1];
					int methodsize = fileSizes.get(fileStruct.getKey()) - currentLoc;
					if(methodsize == 0) //In lined functions should still be at least one.
						methodsize++;
					//System.out.println(fileStruct.getKey() + ": " + currentLoc);
					methodSizes.put(fileStruct.getKey() + "," + actualName, methodsize);
				}
				
			}

			try {
				PrintWriter writer = new PrintWriter("MethodSizes.csv");
				writer.println("Project,File,Method,LOC");
				//Write the method information out to a csv file.
				for(Map.Entry<String, Integer> nextMethod : methodSizes.entrySet())
				{
					String project = nextMethod.getKey().split("/")[0];
					writer.println(project + "," + nextMethod.getKey() + "," + nextMethod.getValue());
				}
				writer.close();
			} 
			catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} 
		catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

}
