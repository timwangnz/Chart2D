package org.jobs.model;

import org.sixstreams.search.data.java.ListOfValues;

public class JobTermLov extends ListOfValues{
	

	public JobTermLov()
	{
		lov.put("4", "Part Time");
		lov.put("6", "Intern");
		lov.put("5", "Temp");
		lov.put("2", "Contract");
		lov.put("3", "Contract to Hire");
		lov.put("1", "Full Time");
	}
}
