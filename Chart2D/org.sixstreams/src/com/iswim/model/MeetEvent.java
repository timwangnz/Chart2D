package com.iswim.model;

import java.util.Date;


public class MeetEvent extends Event
{

	private Date eventDate;

	private long estimateTime;

	private long meetId;

	public void setEstimateTime(long estimateTime)
	{
		this.estimateTime = estimateTime;
	}

	public long getEstimateTime()
	{
		return estimateTime;
	}

	public void setEventDate(Date eventDate)
	{
		this.eventDate = eventDate;
	}

	public Date getEventDate()
	{
		return eventDate;
	}

	public void setMeetId(long meetId)
	{
		this.meetId = meetId;
	}

	public long getMeetId()
	{
		return meetId;
	}
}
