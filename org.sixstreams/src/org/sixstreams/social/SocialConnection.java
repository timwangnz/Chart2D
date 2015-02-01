package org.sixstreams.social;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "resourceName")
public class SocialConnection extends IdObject
{
	/**
	 * Resource id the creator to connect to
	 */
	private String resourceId;
	/**
	 * Readable name for the resource
	 */
	private String resourceName;
	/**
	 * location for getting avatar
	 */
	private String resourceUrl;
	
	//this is a person
	/**
	 * This is readable name of the creator, or owner of this conneciton
	 */
	private String createdByName;
	/**
	 * This is a resouce, e.g. avatar for the creator.
	 */
	private String createdByUrl;
	
	public String getResourceId()
	{
		return resourceId;
	}
	public void setResourceId(String resourceId)
	{
		this.resourceId = resourceId;
	}
	public String getResourceName()
	{
		return resourceName;
	}
	public void setResourceName(String resourceName)
	{
		this.resourceName = resourceName;
	}
	public String getResourceUrl()
	{
		return resourceUrl;
	}
	public void setResourceUrl(String resourceUrl)
	{
		this.resourceUrl = resourceUrl;
	}
	public String getCreatedByName()
	{
		return createdByName;
	}
	public void setCreatedByName(String createdByName)
	{
		this.createdByName = createdByName;
	}
	public String getCreatedByUrl()
	{
		return createdByUrl;
	}
	public void setCreatedByUrl(String createdByUrl)
	{
		this.createdByUrl = createdByUrl;
	}
}
