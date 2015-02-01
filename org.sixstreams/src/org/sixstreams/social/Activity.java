package org.sixstreams.social;

import java.util.Date;

import org.sixstreams.rest.GoodCache;
import org.sixstreams.rest.IdObject;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.data.java.annotations.Searchable; 
import org.sixstreams.search.util.ContextFactory; 

@Searchable(title = "context", isSecure = false)
public class Activity extends IdObject
{
	//resource teh activity is about
	private String resourceType;
	private String resourceId; 
	
	//context info for the activity
	//create, update, delete
	private String context;
	//subject of this activity
	private String subject;
	private String status;
	
	public String getStatus()
	{
		return status;
	}

	public void setStatus(String status)
	{
		this.status = status;
	}
	
	public Activity()
	{
		super();
	}
	
	public Activity(IdObject object, String context)
	{
		super();
		SearchContext ctx = ContextFactory.getSearchContext();
		Person person = ctx.getUser();
		setCreatedBy(person.getId());
		setAppId(ctx.getAppId());
		setCreatedByName(person.getId() + ":" + person.getFirstName() == null ? "Unknown" : person.getFirstName() + " " + person.getLastName());
		this.context = context;
		this.setDateCreated(new Date());
		//like
		this.resourceType = object.getClass().getName(); 
		this.resourceId = object.getId();
		//subject
		if (object instanceof SocialAction)
		{
			SocialAction action = (SocialAction) object;
			this.subject = action.getAboutType();
		}
		else
		{
			this.subject = object.getClass().getName();
		}
		GoodCache.updateActivityFor(person, this);
	}

	public String getResourceType()
	{
		return resourceType;
	}
 
	public void setResourceType(String resourceType)
	{
		this.resourceType = resourceType;
	}

	public String getResourceId()
	{
		return resourceId;
	}

	public void setResourceId(String resourceId)
	{
		this.resourceId = resourceId;
	}

	public String getContext()
	{
		return context;
	}
 
	public void setContext(String context)
	{
		this.context = context;
	}
 
	public String getSubject()
	{
		return subject;
	}

	public void setSubject(String subject)
	{
		this.subject = subject;
	}
}
