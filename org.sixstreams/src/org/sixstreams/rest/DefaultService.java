package org.sixstreams.rest;

import java.util.logging.Logger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.Constants;
import org.sixstreams.rest.writers.ResultWriter;
import org.sixstreams.rest.writers.ResultWriterProxy;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.social.Activity;

public class DefaultService implements ActionService
{

	protected static Logger sLogger = Logger.getLogger(DefaultService.class.getName());
	protected ResourceDescriptor rd;
	protected ResultWriter writer;

	public void recordActivity(PersistenceManager pm, IdObject object, String action)
	{
		try
		{
			Activity activity = new Activity(object, action);
			//
			//String id = activity.getCreatedBy();
			//QueryBuilder queryBuilder = new QueryBuilder();
			//queryBuilder.setLimit(200).setOffset(1).setQuery(id).setFilters(filters).
			//get all my followers, and add activity to their stream
			//
			pm.insert(activity);
			//
			//hadoop this thing
			//
			//AmazonSimpleDBAsyncClient 
		}
		catch (IndexingException e)
		{
			sLogger.severe("Failed to record an activity");
		}
	}

	public void parseRequest(HttpServletRequest request, HttpServletResponse response) throws RestfulException
	{
		SearchContext ctx = ContextFactory.getSearchContext();
		rd = new ResourceDescriptor(request);
		ctx.setAppId(rd.getApplicationId());
		ctx.setAppKey(rd.getApplicationKey());
		
		if (!rd.getResource().equals(Constants.SEARCH_CONTENT) && !rd.getResource().equals(Constants.SEARCH_ICON))
		{
			SearchableObject object = MetaDataManager.getSearchableObject(rd.getResource());
			if (object == null)
			{
				throw new RestfulException(401, "Failed to load " + rd.getResource(), "parseRequest");
			}
			ctx.setSearchableObject(object);
		}
		else
		{
			if (rd.getParentResource() != null)
			{
				SearchableObject object = MetaDataManager.getSearchableObject(rd.getParentResource());
				ctx.setSearchableObject(object);
			}
		}

		ctx.setAttribute(Constants.RESOURCE_DESCRIPTOR, rd);
		writer = new ResultWriterProxy(rd.getFormat());

		response.setContentType(writer.getContentType());

		if (rd.getFieldsRequested() != null)
		{
			writer.setIncludingRules(rd.getFieldsRequested());
		}
	}

	public boolean performService(HttpServletRequest request, HttpServletResponse response)
	{
		return false;
	}

}
