package com.iswim.model;

import java.util.Date;
 
 
public class PersonProperty extends Inheritable
{

	private String ownerId;

	private String name;

	private String value;

	private String type;

	private Date lastUpdated;
	public void setName(String name)
	{
		this.name = name;
	}
	public String getName()
	{
		return name;
	}
	public void setValue(String value)
	{
		this.value = value;
	}
	public String getValue()
	{
		return value;
	}
	public void setType(String type)
	{
		this.type = type;
	}
	public String getType()
	{
		return type;
	}
	public void setLastUpdated(Date lastUpdated)
	{
		this.lastUpdated = lastUpdated;
	}
	public Date getLastUpdated()
	{
		return lastUpdated;
	}
	public void setOwnerId(String ownerId)
	{
		this.ownerId = ownerId;
	}
	public String getOwnerId()
	{
		return ownerId;
	}
	
}
