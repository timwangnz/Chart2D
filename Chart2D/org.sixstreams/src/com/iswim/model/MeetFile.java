package com.iswim.model;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
 

@Searchable(title = "name")
public class MeetFile
{

	@SearchableAttribute(isKey=true)
	private String name;
	public MeetFile()
	{
		
	}
	public MeetFile(String name)
	{
		this.name = name;
	}
	
	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}
}
