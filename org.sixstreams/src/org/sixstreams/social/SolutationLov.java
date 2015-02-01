package org.sixstreams.social;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class SolutationLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	
	public SolutationLov()
	{
		lov.put("1", "Mr.");
		lov.put("2", "Mrs.");
		lov.put("3", "Miss");
		lov.put("4", "Dr.");
		lov.put("5", "Sir");
	}
}
