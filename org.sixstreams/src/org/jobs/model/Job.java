package org.jobs.model;

import java.util.Date;
import java.util.List;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

import org.sixstreams.social.SocialLocatable;

@Searchable(title = "title", isSecure=false)
public class Job extends SocialLocatable
{
	private String title;
	private String summary;
	private String jobDesc;
	private String keywords;
	private String company;

	private List<String> responsibilities;
	private List<String> skillset;
	private List<String> qualifications;
	private List<String> featurs; // 401k etc.

	private String payRate;
	
	@SearchableAttribute(lov="org.jobs.model.JobTermLov")
	private String taxTerm;
	@SearchableAttribute(lov="org.jobs.model.JobCareerLov")
	private String careerLevel;
	@SearchableAttribute(lov="org.jobs.model.JobEducationLov")
	private String educationLevel;

	@SearchableAttribute(lov="org.jobs.model.JobExperienceLov")
	private int yearsOfExperience;
	
	private boolean telecommute;
	
	private String travel;

	@SearchableAttribute(lov="org.jobs.model.JobIndustryLov")
	private String industry;

	// status
	private String status;
	private Date closeDate;

	private String employer;
	private String contact;

	public Job()
	{
		super();
	}
	public String getTitle()
	{
		return title;
	}

	public void setTitle(String title)
	{
		this.title = title;
	}

	public List<String> getRequirements()
	{
		return responsibilities;
	}

	public void setRequirements(List<String> responsibilities)
	{
		this.responsibilities = responsibilities;
	}

	public String getEmployer()
	{
		return employer;
	}

	public void setEmployer(String employer)
	{
		this.employer = employer;
	}

	public String getSummary()
	{
		return summary;
	}

	public void setSummary(String summary)
	{
		this.summary = summary;
	}

	public List<String> getResponsibilities()
	{
		return responsibilities;
	}

	public void setResponsibilities(List<String> responsibilities)
	{
		this.responsibilities = responsibilities;
	}

	public List<String> getSkillset()
	{
		return skillset;
	}

	public void setSkillset(List<String> skillset)
	{
		this.skillset = skillset;
	}

	public List<String> getQualifications()
	{
		return qualifications;
	}

	public void setQualifications(List<String> qualifications)
	{
		this.qualifications = qualifications;
	}

	public String getPayRate()
	{
		return payRate;
	}

	public void setPayRate(String payRate)
	{
		this.payRate = payRate;
	}

	public String getTaxTerm()
	{
		return taxTerm;
	}

	public void setTaxTerm(String taxTerm)
	{
		this.taxTerm = taxTerm;
	}

	public boolean isTelecommute()
	{
		return telecommute;
	}

	public void setTelecommute(boolean telecommute)
	{
		this.telecommute = telecommute;
	}

	public String getTravel()
	{
		return travel;
	}

	public void setTravel(String travel)
	{
		this.travel = travel;
	}

	public String getIndustry()
	{
		return industry;
	}

	public void setIndustry(String industry)
	{
		this.industry = industry;
	}

	public String getStatus()
	{
		return status;
	}

	public void setStatus(String status)
	{
		this.status = status;
	}

	public Date getCloseDate()
	{
		return closeDate;
	}

	public void setCloseDate(Date closeDate)
	{
		this.closeDate = closeDate;
	}

	public String getContact()
	{
		return contact;
	}

	public void setContact(String contact)
	{
		this.contact = contact;
	}

	public List<String> getFeaturs()
	{
		return featurs;
	}

	public void setFeaturs(List<String> featurs)
	{
		this.featurs = featurs;
	}

	public String getJobDesc()
	{
		return jobDesc;
	}

	public void setJobDesc(String jobDesc)
	{
		this.jobDesc = jobDesc;
	}

	public String getCompany()
	{
		return company;
	}

	public void setCompany(String company)
	{
		this.company = company;
	}

	public String getKeywords()
	{
		return keywords;
	}

	public void setKeywords(String keywords)
	{
		this.keywords = keywords;
	}

	public String getCareerLevel()
	{
		return careerLevel;
	}

	public void setCareerLevel(String careerLevel)
	{
		this.careerLevel = careerLevel;
	}

	public String getEducationLevel()
	{
		return educationLevel;
	}

	public void setEducationLevel(String educationLevel)
	{
		this.educationLevel = educationLevel;
	}

	public int getYearsOfExperience()
	{
		return yearsOfExperience;
	}

	public void setYearsOfExperience(int yearsOfExperience)
	{
		this.yearsOfExperience = yearsOfExperience;
	}
}
