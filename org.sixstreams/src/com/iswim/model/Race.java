package com.iswim.model;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
@Searchable(title="swimmerId")
public class Race extends Event implements Comparable<Race>
{

	@SearchableAttribute(facetName="team", facetPath="team")
	private String team;

	@SearchableAttribute
	private String meet;

	@SearchableAttribute
	private long time = -1;

	@SearchableAttribute
	private Date date;

	@SearchableAttribute
	private Date swimmerDoB;

	@SearchableAttribute
	private int swimmerAge;

	@SearchableAttribute
	private String firstName;

	@SearchableAttribute
	private String lastName;

	@SearchableAttribute
	private String middleName;

	@SearchableAttribute
	private String LSC;
	

	@SearchableAttribute
	private String swimmerUSSNo;
	
	public String getSwimmerUSSNo()
	{
		return swimmerUSSNo;
	}

	public void setSwimmerUSSNo(String swimmerUSSNo)
	{
		this.swimmerUSSNo = swimmerUSSNo;
	}
	
	public String getLSC()
	{
		return LSC;
	}
	public void setLSC(String lSC)
	{
		LSC = lSC;
	}

	public String getMiddleName()
	{
		return middleName;
	}

	public Date getSwimmerDoB()
	{
		return swimmerDoB;
	}
	
	public void setSwimmerDoB(Date swimmerDoB)
	{
		this.swimmerDoB = swimmerDoB;
	}
	
	public String toString()
	{
		return swimmerUSSNo + "("  + firstName + " " + lastName + ")  "+ 
			getAge() + " "  + 
			swimmerAge + " "  + 
			getDistance() + " " + 
			getStroke() + " " + 
			getCourse() + " " + 
			time + " " + 
			date + " at " + this.getMeet();
	}
	
	public void assign(Race race)
	{
		super.assign(race);
		this.date = race.date;
		this.swimmerDoB = race.swimmerDoB;
		this.firstName = race.firstName;
		this.lastName = race.lastName;
		this.middleName = race.middleName;
		this.team = race.team;
		this.meet = race.meet;
		this.time = race.time;
		this.LSC = race.LSC;
		this.swimmerAge = race.swimmerAge;
		this.swimmerUSSNo = race.swimmerUSSNo;
	}

	public void setMiddleName(String middleName)
	{
		this.middleName = middleName;
	}

	public String getFirstName()
	{
		return firstName;
	}

	public void setFirstName(String firstName)
	{
		this.firstName = firstName;
	}

	public String getLastName()
	{
		return lastName;
	}

	public void setLastName(String lastName)
	{
		this.lastName = lastName;
	}

	public long getTime()
	{
		return time;
	}

	public void setTime(long time)
	{
		this.time = time;
	}

	public void setMeet(String meet)
	{
		this.meet = meet;
	}

	public String getMeet()
	{
		return meet;
	}

	public void setTeam(String team)
	{
		this.team = team;
	}

	public String getTeam()
	{
		return team;
	}

	public void setDate(Date date)
	{
		this.date = date;
	}

	public Date getDate()
	{
		return date;
	}

	public void setSwimmerAge(int swimmerAge)
	{
		this.swimmerAge = swimmerAge;
	}
	
	public int getSwimmerAge()
	{
		return swimmerAge;
	}

	@Override
	public int compareTo(Race arg0) 
	{
		return this.time < ((Race) arg0).time ? -1 : 1;
	}
}
