package org.sixstreams.social;

import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "rate", isSecure=false)
public class Rating extends SocialAction
{
	private int rate; // 0 - 5;
	private String comment;

	public Rating()
	{
		super();
	}

	public void setRate(int rate)
	{
		this.rate = rate;
	}

	public int getRate()
	{
		return rate;
	}

	public void setComment(String comment)
	{
		this.comment = comment;
	}

	public String getComment()
	{
		return comment;
	}

	public String getVerb()
	{
		return this.comment == null ? "rates" : "comments";
	}
	
	public void onDelete()
	{
		//does nothting
	}
	public void onCreate()
	{
		//does nothting
	}
	public void preCreate()
	{
		
	}

}
