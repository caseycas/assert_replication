import java.util.List;


public class Utilities {

	public static <T> String ArrayAsCsv(T[] array)
	{
		String output = "";

		for(int i = 0;i < array.length; i++)
		{
			output += array[i].toString();
			if(i+1 !=array.length)
				output += ",";
		}
		return output;
	}
	
	public static <T> String ListAsCsv(List<T> list)
	{
		return ArrayAsCsv(list.toArray());
	}
}
