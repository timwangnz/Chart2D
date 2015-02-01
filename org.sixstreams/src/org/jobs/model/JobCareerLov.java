package org.jobs.model;

import org.sixstreams.search.data.java.ListOfValues;

public class JobCareerLov extends ListOfValues
{

	public JobCareerLov()
	{
		lov.put("0", "No Requirements");
		lov.put("12","Student (High School)");
		lov.put("13","Student (Undergraduate/Graduate)");
		lov.put("7","Entry Level");
		lov.put("9","Experienced (Non-Manager)");
		lov.put("10","Manager (Manager/Supervisor of Staff)");
		lov.put("8","Executive (SVP, VP, Department Head, etc)");
		lov.put("11","Senior Executive (President, CFO, etc)");
	}
}
