package org.sixstreams.social;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

@Searchable(title = "screenName")
public class Person extends SocialLocatable
{
	@SearchableAttribute(lov="org.sixstreams.social.SolutationLov")
	private String solutation;
	
	private String name;

	private String citizen;

	private Date age;

	private String firstName;

	private String lastName;

	private String middleName;

	private Date dateOfBirth;

	private String gender;

	private Integer status = 0;

	private String username;

	private String screenName;

	private String jobTitle;
	
	public String getJobTitle()
	{
		return jobTitle;
	}

	public void setJobTitle(String jobTitle)
	{
		this.jobTitle = jobTitle;
	}

	private float points;

	public Person()
	{
		super();
	}

	public Person(String name)
	{
		this.name = name;
	}

	public Integer getStatus()
	{
		if (status == null)
		{
			status = 0;
		}
		return status;
	}

	public void setStatus(Integer status)
	{
		this.status = status;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getName()
	{
		return name;
	}

	public String getMiddleName()
	{
		return middleName;
	}

	public void setMiddleName(String middleName)
	{
		this.middleName = middleName;
	}

	public String getGender()
	{
		return gender;
	}

	public void setGender(String gender)
	{
		this.gender = gender;
	}

	public void setCitizen(String citizen)
	{
		this.citizen = citizen;
	}

	public String getCitizen()
	{
		return citizen;
	}

	public void setAge(Date age)
	{
		this.age = age;
	}

	public Date getAge()
	{
		return age;
	}

	public void setFirstName(String firstName)
	{
		this.firstName = firstName;
	}

	public String getFirstName()
	{
		return firstName;
	}

	public void setLastName(String lastName)
	{
		this.lastName = lastName;
	}

	public String getLastName()
	{
		return lastName;
	}

	public void setDateOfBirth(Date dateOfBirth)
	{
		this.dateOfBirth = dateOfBirth;
	}

	public Date getDateOfBirth()
	{
		return dateOfBirth;
	}

	public String getContent()
	{
		return toString();
	}

	public void setUsername(String username)
	{
		this.username = username;
	}

	public String getUsername()
	{
		return username;
	}

	public void setScreenName(String screenName)
	{
		this.screenName = screenName;
	}

	public String getScreenName()
	{
		return screenName;
	}

	public String getSolutation()
	{
		return solutation;
	}

	public void setSolutation(String solutation)
	{
		this.solutation = solutation;
	}

	public float getPoints()
	{
		return points;
	}

	public void setPoints(float points)
	{
		this.points = points;
	}

	public String toString()
	{
		return firstName == null ? screenName : firstName + " " + lastName;
	}
}
