package org.jobs.model;

import java.io.Serializable;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

@Searchable(title = "description")
public class Education implements Serializable
{
	@SearchableAttribute(lov="org.jobs.model.DegreeLov")
	private String degree;
	private String yearStart;
	private String yearEnd;
	private String school;
	private String city;
	private String country;
	private String description;

	public String getDegree()
	{
		return degree;
	}
	public void setDegree(String degree)
	{
		this.degree = degree;
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
	public String getSchool()
	{
		return school;
	}
	public void setSchool(String school)
	{
		this.school = school;
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
