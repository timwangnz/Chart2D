package org.jobs.model;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;

public class SkillSetLov extends ListOfValues{
	
	private Map<String, Object> lov = new HashMap<String, Object>();
	
	public Map<String, Object> getLov()
	{
		return lov;
	}
	
	public SkillSetLov()
	{
		lov.put("14", "Accounting and Auditing Services");
		lov.put("15", "Advertising and PR Services");
		lov.put("16", "Aerospace and Defense");
		lov.put("17", "Agriculture/Forestry/Fishing");
		lov.put("18", "Architectural and Design Services");
		lov.put("19", "Automotive and Parts Mfg");
		lov.put("20", "Automotive Sales and Repair Services");
		lov.put("21", "Banking");
		lov.put("67", "Wholesale Trade/Import-Export");
	}
}
