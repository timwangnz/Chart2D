package org.jobs.model;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class ResumeSearchabilityLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	public ResumeSearchabilityLov()
	{
		lov.put("public",  "Public");
		lov.put("restricted",  "Restricted");
		lov.put("network",  "Network");
		lov.put("private",  "Private");
	}
}
