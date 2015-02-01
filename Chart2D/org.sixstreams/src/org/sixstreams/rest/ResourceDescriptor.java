package org.sixstreams.rest;

import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.sixstreams.Constants;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.MetaEngineInstance;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;

public class ResourceDescriptor
{
	private String format;
	private List<String> fieldsRequested;

	private String resource;
	private String resourceId;
	private String parentResource = null;
	private String parentResourceId = null;
	private String applicationKey;
	private String applicationId;
	public String getParentResource()
	{
		return parentResource;
	}

	public String getParentResourceId()
	{
		return parentResourceId;
	}
	//
	//the uri must be formed according to following rules
	//contextPath/contextName/object.class.name/id/child.object.class.name/id
	//where contextName can be set from sixstreams.properties
	//as value to org.sixstreams.web.context.name
	//if not set, default would b sixstreams
	//id can be  one of the following
	//list - returns a list of objects per query parameters. Currently, post, delete, and put does not work on this object either
	//definition - returns definition of the object - this is a read only object, so post, put, and delete does not work on this object
	//primarykey - returns object per key
	//
	//action is described as
	//POST - create and upload
	//PUT - update
	//DELETE - delete
	//GET - get details
	
	public ResourceDescriptor(HttpServletRequest request)
	{
		String uri = request.getRequestURI();
		
		applicationId = request.getHeader(Constants.APPLICATION_ID);
		applicationKey = request.getHeader(Constants.APPLICATION_KEY);
		
		String contextName = MetaDataManager.getProperty("org.sixstreams.web.context.name");
		
		if (contextName == null)
		{
			contextName = "api";
		}
		
		uri = uri.substring(uri.indexOf(contextName));
		String[] uriElements = uri.split("/");

		if (uriElements.length < 2)
		{
			throw new RestfulException(401, "Invalid request " + uri, "Request");
		}

		String fields = request.getParameter("fields");

		fieldsRequested = null;
		if (fields != null)
		{
			fieldsRequested = Arrays.asList(fields.split(","));
		}

		format = request.getParameter("type");
		
		if (format == null)
		{
			format = Constants.DEFAULT_FORMAT;
		}
		
		resource = uriElements[1];
		if (uriElements.length > 2)
		{
			resourceId = uriElements[2];
		}

		if (uriElements.length > 3)
		{
			parentResource = resource;
			parentResourceId = resourceId;
			resource = uriElements[3];
			if (!resource.equals("content"))
			{
				getForeignKey();
			}
		}
		
		if (uriElements.length > 4)
		{
			resourceId = uriElements[4];
		}
	}
	
	private String forgeignKey;
	
	public String getForgeignKey()
	{
		return forgeignKey;
	}

	private void getForeignKey()
	{
		if (parentResource == null || resource == null)
		{
			//must have these resources to determine foriegn keys
			return;
		}
        SearchableObject object = MetaDataManager.getSearchableObject(resource);
        
        if (object == null)
        {
        	return;
        }
        
        for	(AttributeDefinition fd : object.getDocumentDef().getAttrDefs())
        {
          String foreignKeyObject = fd.getForeignKey();
      	  if (foreignKeyObject != null && foreignKeyObject.equals(parentResource))
      	  {
      		  forgeignKey = fd.getName();
      	  }
        }
	}
	
	public SearchableGroup getResourceObject()
	{
		for (MetaEngineInstance engine: MetaDataManager.getEngineInstances())
		{
			SearchableGroup group = MetaDataManager.getSearchableGroup(engine.getId(), resource);
			if (group != null)
			{
				return group;
			}
		}
		return null;
	}

	SearchableGroup getResourceDefinition()
	{
		for (MetaEngineInstance engine: MetaDataManager.getEngineInstances())
		{
			SearchableGroup group = MetaDataManager.getSearchableGroup(engine.getId(), resourceId);
			if (group != null)
			{
				return group;
			}
		}
		return null;
	}

	public String getFormat()
	{
		return format;
	}

	public List<String> getFieldsRequested()
	{
		return fieldsRequested;
	}

	public void setResource(String resource)
	{
		this.resource = resource;
	}

	public String getResource()
	{
		return resource;
	}

	public String getResourceId()
	{
		return resourceId;
	}

	public String getApplicationKey()
	{
		return applicationKey;
	}

	public void setApplicationKey(String applicationKey)
	{
		this.applicationKey = applicationKey;
	}

	public String getApplicationId()
	{
		return applicationId;
	}

	public void setApplicationId(String applicationId)
	{
		this.applicationId = applicationId;
	}

}
