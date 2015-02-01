package org.sixstreams.rest;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.search.util.GUIDUtil;

public class IdObject
{
	@SearchableAttribute(isKey = true)
	private String id;
	private Date dateCreated;
	private String createdBy;
	private String createdByName;
	// 0 everyone, 1 friends, 2 self
	@SearchableAttribute(lov="org.sixstreams.social.VisibilityLov")
	private String visibility = "0";//public by default
	// to partition the object by application Id
	private String appId;
	
	public void setAppId(String applicationId)
	{
		this.appId = applicationId;
	}

	public String getAppId()
	{
		return appId;
	}
	
	public String getVisibility()
	{
		return visibility;
	}

	public void setVisibility(String visibility)
	{
		this.visibility = visibility;
	}

	public String getCreatedBy()
	{
		return createdBy;
	}

	public void setCreatedBy(String createdBy)
	{
		this.createdBy = createdBy;
	}

	public IdObject()
	{
		super();
		id = GUIDUtil.getGUID(this);
	}

	public String getId()
	{
		return id;
	}

	public void setId(String id)
	{
		this.id = id;
	}

	public Date getDateCreated()
	{
		return dateCreated;
	}

	public void setDateCreated(Date dateCreated)
	{
		this.dateCreated = dateCreated;
	}

	public void setCreatedByName(String createdByName)
	{
		this.createdByName = createdByName;
	}

	public String getCreatedByName()
	{
		return createdByName;
	}
}
