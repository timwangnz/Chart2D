package org.jobs.model;

import java.util.Date;
import java.util.List;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.SocialLocatable;

@Searchable(title = "name")
public class Resume extends SocialLocatable
{
	private String keywords;
	private String summary;

		//owner
	private String applicant;

	private String name;
	
	private String phone;
	private String email;
	
	private String position;
	
	private String workAuthorization;
	
	private Date dateAvailable;

	private List<Experience> experience;
	private List<Education> education;
	
	@SearchableAttribute(lov="org.jobs.model.SkillSetLov")
	private List<String> skillset;
	
	private List<String> certifications;

	public String getKeywords()
	{
		return keywords;
	}

	public void setKeywords(String keywords)
	{
		this.keywords = keywords;
	}

	public List<Experience> getExperience()
	{
		return experience;
	}

	public void setExperience(List<Experience> experience)
	{
		this.experience = experience;
	}

	public List<Education> getEducation()
	{
		return education;
	}

	public void setEducation(List<Education> education)
	{
		this.education = education;
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
		return certifications;
	}

	public void setQualifications(List<String> qualifications)
	{
		this.certifications = qualifications;
	}

	public void setUser(String user)
	{
		this.applicant = user;
	}

	public String getUser()
	{
		return applicant;
	}

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getPosition()
	{
		return position;
	}

	public void setPosition(String position)
	{
		this.position = position;
	}

	public String getWorkAuthorization()
	{
		return workAuthorization;
	}

	public void setWorkAuthorization(String workAuthorization)
	{
		this.workAuthorization = workAuthorization;
	}

	public Date getDateAvailable()
	{
		return dateAvailable;
	}

	public void setDateAvailable(Date dateAvailable)
	{
		this.dateAvailable = dateAvailable;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public String getPhone()
	{
		return phone;
	}

	public void setPhone(String phone)
	{
		this.phone = phone;
	}

	public String getEmail()
	{
		return email;
	}

	public void setEmail(String email)
	{
		this.email = email;
	}
}
