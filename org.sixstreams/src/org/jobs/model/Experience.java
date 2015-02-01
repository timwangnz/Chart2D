package org.jobs.model;

import java.io.Serializable;

import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "title")
public class Experience implements Serializable
{
	private String title;
	private String yearStart;
	private String yearEnd;
	private String company;
	private String city;
	private String country;
	private String description;
	private String resume;

	public Experience()
	{
		
	}
	
	Experience(String title, String yearStart, String yearEnd, String company)
	{
		this.title = title;
		this.yearEnd = yearEnd;
		this.yearStart = yearStart;
		this.company = company;
	}
	
	public String getResume()
	{
		return resume;
	}

	public void setResume(String resume)
	{
		this.resume = resume;
	}

	public String getTitle()
	{
		return title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}
	public String getYearStart()
	{
		return yearStart;
	}
	public void setYearStart(String yearStart)
	{
		this.yearStart = yearStart;
	}
	public String getYearEnd()
	{
		return yearEnd;
	}
	public void setYearEnd(String yearEnd)
	{
		this.yearEnd = yearEnd;
	}
	public String getCompany()
	{
		return company;
	}
	
	public void setCompanyName(String company)
	{
		this.company = company;
	}
	
	public String getCity()
	{
		return city;
	}
	
	public void setCity(String city)
	{
		this.city = city;
	}
	public String getCountry()
	{
		return country;
	}
	public void setCountry(String country)
	{
		this.country = country;
	}
	public String getDescription()
	{
		return description;
	}
	public void setDescription(String description)
	{
		this.description = description;
	}
}
