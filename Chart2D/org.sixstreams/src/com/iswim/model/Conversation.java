package com.iswim.model;


public class Conversation extends Inheritable
{

	private String to;
	private String from;
	

	public String getFrom()
	{
		return from;
	}
	public void setFrom(String from)
	{
		this.from = from;
	}
	public String getTo()
	{
		return to;
	}
	public void setTo(String to)
	{
		this.to = to;
	}
	
}
