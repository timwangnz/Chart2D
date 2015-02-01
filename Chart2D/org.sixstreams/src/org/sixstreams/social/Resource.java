package org.sixstreams.social;


import org.sixstreams.rest.RestBaseResource;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.util.GUIDUtil;

@Searchable(title="name", isSecure=false)
public class Resource extends Socialable implements RestBaseResource
{
	//person how create this
	private String owner;
	
	//object this resource attached to, e.g. 
	private String parentId;
	private String parentType;
	
	//icon for this resource
	private String iconId;

	private String iconUrl;
	//caption
	private String name;
	
	//content details
	private int contentLength;
	private String contentUrl;
	private String contentType;
	
	public Resource ()
	{
		super();
		this.iconId = GUIDUtil.getGUID(this);
	}

	public int getContentLength()
	{
		return contentLength;
	}

	public void setContentLength(int contentLength)
	{
		this.contentLength = contentLength;
	}

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getContentType()
	{
		return contentType;
	}
	
	public void setContentType(String contentType)
	{
		this.contentType = contentType;
	}
	
	public String getOwner()
	{
		return owner;
	}
	
	public void setOwner(String owner)
	{
		this.owner = owner;
	}
	public String getParentId()
	{
		return parentId;
	}
	
	public void setParentId(String parentId)
	{
		this.parentId = parentId;
	}
	
	public String getContentUrl()
	{
		return contentUrl;
	}
	
	public void setContentUrl(String contentUrl)
	{
		this.contentUrl = contentUrl;
	}

	public String getIconUrl()
	{
		return iconUrl;
	}

	public void setIconUrl(String iconUrl)
	{
		this.iconUrl = iconUrl;
	}

	public void setIconId(String iconId)
	{
		this.iconId = iconId;
	}

	public String getIconId()
	{
		return iconId;
	}
	
	public String getResourceName()
	{
		return contentType;
	}
	
	public String getParentType()
	{
		return parentType;
	}

	public void setParentType(String parentType)
	{
		this.parentType = parentType;
	}
}
