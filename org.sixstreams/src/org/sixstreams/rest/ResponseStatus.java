package org.sixstreams.rest;

import org.sixstreams.rest.writers.JSONWriter;

public class ResponseStatus implements java.io.Serializable
{
	private String status;
	private String message;
	private String title;
	private String context;
	
	public ResponseStatus(String title, String status, String message, String context)
	{
		this.title = title;
		this.status = status;
		this.context = context;
		this.message = message;
	}
	public  String toString()
	{
		JSONWriter writer = new JSONWriter();
		return writer.toJson(this);	    
	}
	public String getStatus()
	{
		return status;
	}
	
	public void setStatus(String status)
	{
		this.status = status;
	}
	
	public String getMessage()
	{
		return message;
	}
	public void setMessage(String message)
	{
		this.message = message;
	}
	public String getTitle()
	{
		return title;
	}
	public void setTitle(String title)
	{
		this.title = title;
	}
	public String getContext()
	{
		return context;
	}
	public void setContext(String context)
	{
		this.context = context;
	}

}
