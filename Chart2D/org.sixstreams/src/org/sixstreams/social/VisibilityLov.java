package org.sixstreams.social;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class VisibilityLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	
	public VisibilityLov()
	{
		lov.put("0","Public");
		lov.put("1","Connected");
		lov.put("2","Self");
	}
}
