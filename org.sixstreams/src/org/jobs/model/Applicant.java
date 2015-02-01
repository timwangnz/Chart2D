package org.jobs.model;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.Person;

@Searchable(title = "username", isSecure=false)
public class Applicant extends Person
{
	@SearchableAttribute(facetName = "industry", facetPath = "industry", lov="org.jobs.model.JobIndustryLov")
	private String industry;
	@SearchableAttribute(facetName="jobType", facetPath="jobType", lov="org.jobs.model.ApplicantJobTypeLov")
	private String jobType;
	@SearchableAttribute(facetName="jobStatus", facetPath="jobStatus", lov="org.jobs.model.ApplicantJobStatusLov")
	private String jobStatus;
	
	private String company;
	
	private String companyId;
	
	public String getIndustry()
	{
		return industry;
	}
	
	public void setIndustry(String industry)
	{
		this.industry = industry;
	}
	public String getJobType()
	{
		return jobType;
	}
	public void setJobType(String jobType)
	{
		this.jobType = jobType;
	}
	public String getJobStatus()
	{
		return jobStatus;
	}
	public void setJobStatus(String jobStatus)
	{
		this.jobStatus = jobStatus;
	}
	
	public String getCompany()
	{
		return company;
	}

	public void setCompany(String company)
	{
		this.company = company;
	}

	public String getCompanyId()
	{
		return companyId;
	}

	public void setCompanyId(String companyId)
	{
		this.companyId = companyId;
	}
}
