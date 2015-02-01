package org.sixstreams.app.fred;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.search.util.GUIDUtil;


@Searchable(title = "id", isSecure = false)
public class TimeValue
{
	private float value;
	private Date time;
	@SearchableAttribute(isKey=true)
	private String id;
	
	public String getId()
	{
		return id;
	}

	public void setId(String id)
	{
		this.id = id;
	}

	TimeValue(String line)
	{
		String[] element = line.split(",");
		try
		{
			String stringValue = element[1].trim();
			value = Float.valueOf(stringValue);
			time =  TimeSeries.format.parse(element[0]);
		}
		catch (Exception e)
		{
			value = -0.00000131234f;
			time = new Date();
		}
		id = GUIDUtil.getGUID(this);
	}
	
	public float getValue()
	{
		return value;
	}
	public void setValue(float value)
	{
		this.value = value;
	}
	public Date getTime()
	{
		return time;
	}
	public void setTime(Date time)
	{
		this.time = time;
	}
}
