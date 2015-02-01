package com.iswim.model;

import java.util.Date;

public class Friend extends Inheritable
{
	 
	private String myName;
	 
	private String friendName;
	 
	private String screenName;
	 
	private Integer status = 0;
	 
	private Date dateInvited;

	public Integer getStatus()
	{
		return status;
	}
	public void setStatus(Integer status)
	{
		this.status = status;
	}
	public Date getDateInvited()
	{
		return dateInvited;
	}
	public void setDateInvited(Date dateInvited)
	{
		this.dateInvited = dateInvited;
	}
	public String getMyName()
	{
		return myName;
	}
	public void setMyName(String myName)
	{
		this.myName = myName;
	}
	public String getFriendName()
	{
		return friendName;
	}
	public void setFriendName(String friendName)
	{
		this.friendName = friendName;
	}
	public String getScreenName()
	{
		return screenName;
	}
	public void setScreenName(String screenName)
	{
		this.screenName = screenName;
	}
}
