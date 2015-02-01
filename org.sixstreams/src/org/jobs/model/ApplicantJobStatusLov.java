package org.jobs.model;

import org.sixstreams.search.data.java.ListOfValues;

public class ApplicantJobStatusLov extends ListOfValues{
	
	
	public ApplicantJobStatusLov()
	{
		lov.put("1", "Employed, actively looking");
		lov.put("2", "Unemployed, actively looking");
		lov.put("3", "Open to a change");
		lov.put("4", "Make me move");
		lov.put("5", "Sorry, not interested");
		lov.put("6", "In school, wait for me");
		lov.put("7", "Not specified");
	}
}
