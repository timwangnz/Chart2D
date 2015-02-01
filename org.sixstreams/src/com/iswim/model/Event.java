package com.iswim.model;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;

public class Event extends Inheritable
{
	@SearchableAttribute(facetName="gender", facetPath="gender")
	private String gender;
	 
	@SearchableAttribute(facetName="distance", facetPath="distance")
	private int distance;
	  
	@SearchableAttribute(facetName="stroke", facetPath="stroke")
	private String stroke;
	 
	@SearchableAttribute(facetName="age", facetPath="age")
	private String age;
	 
	@SearchableAttribute(facetName="course", facetPath="course")
	private String course;
	
	public void assign(Event event)
	{
		this.distance = event.distance;
		this.stroke = event.stroke;
		this.age = event.age;
		this.course = event.course;
		this.gender = event.gender;
	}

	public String toString()
	{
		return course + ":" + stroke + ":" + age + ":" + distance;

	}

	public void setGender(String gender)
	{
		this.gender = gender;
	}
	public String getGender()
	{
		return gender;
	}

	public void setDistance(int distance)
	{
		this.distance = distance;
	}
	public int getDistance()
	{
		return distance;
	}

	public void setStroke(String stroke)
	{
		this.stroke = stroke;
	}
	public String getStroke()
	{
		return stroke;
	}

	public void setAge(String age)
	{
		this.age = age;
	}
	
	public String getAge()
	{
		return age;
	}

	public void setCourse(String course)
	{
		this.course = course;
	}
	public String getCourse()
	{
		return course;
	}
}
