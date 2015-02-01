package org.jobs.model;

import org.sixstreams.search.data.java.ListOfValues;

public class ApplicantJobTypeLov extends ListOfValues{
	
	public ApplicantJobTypeLov()
	{
		lov.put("1", "Engineer");
		lov.put("2", "Manager");
		lov.put("3", "Executive");
		lov.put("4", "Secretory");
		lov.put("5", "Assistant");
		lov.put("6", "Chef");
		lov.put("7", "Not specified");
	}
}
