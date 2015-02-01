package org.sixstreams.rest.service;

import java.io.IOException;

import java.net.URLDecoder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.Constants;
import org.sixstreams.rest.DefaultService;
import org.sixstreams.rest.IdObject;
import org.sixstreams.rest.RestBaseResource;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.rest.StorageServiceFactory;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.QueryBuilder;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.social.Activity;


/**
 * LIST
 *
 * Entity http://hostname:port/contextPath/objectType/id e.g.
 * http://localhost:8080/rest/org.mypacswim.User/test.again@mypacswim.com
 *
 * method=GET
 *
 * returns json object of given type and id
 *
 * List
 *
 * http://hostname:port/contextPath/objectType/list?query=query&attributes=
 * firstName,lastName&orderBy=firstName,company e.g.
 * http://localhost:8080/sixstreams/org.mypacswim.User/list?query=firstName:tim
 *
 * returns json array of users whose first name is tim result set metadata can
 * also be part of response {result:jsonArray, metadata:jsonObject}
 *
 * Meta
 * http://hostname:port/contextPath/objectType/definition?attributes=firstName
 * ,lastName
 *
 * returns json definition object for the objectType
 *
 * options x-sixstreams-
 *
 * @author anpwang
 *
 */
public class GetService extends DefaultService
{
	public boolean performService(HttpServletRequest request, HttpServletResponse response)
	{
		try
		{
			return this._performService(request, response);
		}
		catch (IOException e)
		{
			throw new RestfulException(500, "Failed fulfil the request due to some internal IO error", e.getMessage());
		}
	}

	public boolean _performService(HttpServletRequest request, HttpServletResponse response) throws IOException
	{
		parseRequest(request, response);

		String resourceName = rd.getResource();// object name
		String resourceId = rd.getResourceId();// id, definition, list, or
												// primarykey
		if (resourceName == null)
		{
			throw new RestfulException(400, "Resource name and id is required for this service" + rd, Constants.ACTION_LIST);
		}

		int offset = Constants.DEFAULT_OFFSET;
		int pageSize = Constants.DEFAULT_PAGE_SIZE;
		//
		// Operation parameters
		//
		List<AttributeFilter> jsonFilters = new ArrayList<AttributeFilter>();
		List<String> facets = new ArrayList<String>();
		// the query string can be one of the following
		// field query, name:
		String queryString = request.getParameter(Constants.SEARCH_KEYWORDS);
		if (queryString != null)
		{
			queryString = URLDecoder.decode(queryString, "UTF-8");
		}
		if (queryString == null || queryString.length() == 0)
		{
			queryString = Constants.SEARCH_WILD_CARD;
		}
		else if (!queryString.equals(Constants.SEARCH_WILD_CARD) && queryString.indexOf(":") != -1)
		{
			jsonFilters.addAll(AttributeFilter.fromQuery(resourceName, queryString));
			queryString = Constants.SEARCH_WILD_CARD;
		}

		String requestPage = request.getParameter(Constants.PAGE);
		String requestPageSize = request.getParameter(Constants.PAGE_SIZE);
		String orderBy = request.getParameter(Constants.ORDER_BY);
		String distanceFilter = request.getParameter(Constants.SEARCH_DISTANCE);
		
		if (requestPageSize != null)
		{
			try
			{
				pageSize = Integer.valueOf(requestPageSize);
				pageSize = pageSize <= 0 ? 100 : pageSize;
			}
			catch (Exception e)
			{
				// e.printStackTrace();
			}
		}

		if (requestPage != null)
		{
			try
			{
				offset = Integer.valueOf(requestPage);
				offset = offset < 0 ? 0 : offset;
			}
			catch (Exception e)
			{
				// e.printStackTrace();
			}
		}

		if (resourceId != null && resourceId.equals(Constants.RESOURCE_NAME_FOR_METADATA))
		{
			SearchableObject object = MetaDataManager.getSearchableObject(resourceName);
			if (object != null)
			{
				response.getOutputStream().print(writer.toString(object).toString());
			}
			else
			{
				throw new RestfulException(404, "Object definition not found, e.g. not annotated for search" + resourceName, "GetService");
			}
		}
		else
		{
			try
			{
				PersistenceManager pm = new PersistenceManager();
				String filterString = request.getParameter(Constants.SEARCH_FILTERS);
				//requesting facets separated by attribute names
				String facetString = request.getParameter(Constants.SEARCH_FACETS);

				if (facetString !=  null)
				{
					facets = Arrays.asList(facetString.split(Constants.SEARCH_ELEMENT_DELIMINATOR));
				}
				
				if (filterString != null)
				{
					jsonFilters.addAll(AttributeFilter.fromQuery(resourceName, filterString));
				}
				
				if (distanceFilter != null)
				{
					//
					// distance= 34.0;-118;24
					// latitude, langitude, distance
					//
					// distance= 0,0,200,200
					// rectangle topleft to bottom right
					try
					{
						String[] distanceElements = distanceFilter.split(Constants.SEARCH_ELEMENT_DELIMINATOR);
						if (distanceElements.length == 3)
						{
							Float latitude = Float.valueOf(distanceElements[0]);
							Float longitude = Float.valueOf(distanceElements[1]);
							Float distance = Float.valueOf(distanceElements[2]);
							distance = distance / 69 / 2;

							AttributeFilter latitudeFilter = new AttributeFilter(Constants.LATITUDE, Constants.NUMBER, latitude - distance, latitude + distance);
							AttributeFilter longitudeFilter = new AttributeFilter(Constants.LONGITUDE, Constants.NUMBER, longitude - distance, longitude + distance);
							jsonFilters.add(longitudeFilter);
							jsonFilters.add(latitudeFilter);
						}
						else if (distanceElements.length == 4)
						{
							Float latitude1 = Float.valueOf(distanceElements[0]);
							Float longitude1 = Float.valueOf(distanceElements[1]);
							Float latitude2 = Float.valueOf(distanceElements[2]);
							Float longitude2 = Float.valueOf(distanceElements[3]);

							AttributeFilter latitudeFilter = new AttributeFilter(Constants.LATITUDE, Constants.NUMBER, latitude1, latitude2);
							AttributeFilter longitudeFilter = new AttributeFilter(Constants.LONGITUDE, Constants.NUMBER, longitude1, longitude2);
							jsonFilters.add(longitudeFilter);
							jsonFilters.add(latitudeFilter);
						}
					}
					catch (Exception e)
					{
						throw new RestfulException(401, "Failed to parse distance filter", e.getMessage());
					}
				}
				//add application id filters
				if (rd.getResource().equals(Activity.class.getName()))
				{
					jsonFilters.add(new AttributeFilter("appId", Constants.STRING, ContextFactory.getSearchContext().getAppId(), Constants.OPERATOR_EQS));
				}
				if (rd.getParentResourceId() != null)
				{
					if (resourceName.equals(Constants.SEARCH_CONTENT))
					{
						Class<?> objectClass = ClassUtil.getClass(rd.getParentResource());

						if (objectClass != null)
						{
							RestBaseResource object = (RestBaseResource) pm.getObjectById(rd.getParentResourceId(), objectClass);
							if(object == null)
							{
								throw new RestfulException(404, "Failed to load resource" + resourceName + " " + rd.getParentResourceId(), "GetService");
							}
							response.setContentType(object.getContentType());
							response.setContentLength(object.getContentLength());

							// note output stream is used for this service
							// resource id is the filename
							// uri should look like
							// objectType/objectId/content/resourceId

							int length = StorageServiceFactory.getService().read(response.getOutputStream(), resourceId, (RestBaseResource) object);
							response.setContentLength(length);
							return true;
						}
					}
					else if (resourceName.equals(Constants.SEARCH_ICON))
					{
						Class<?> objectClass = ClassUtil.getClass(rd.getParentResource());

						if (objectClass != null)
						{
							RestBaseResource object = (RestBaseResource) pm.getObjectById(rd.getParentResourceId(), objectClass);
							if (object == null)
							{
								throw new RestfulException(404, "Resource object not found " + rd.getResourceId(), "GetService");
							}
							response.setContentType(object.getContentType());
							// note output stream is used for this service
							// resource id is the filename
							// uri should look like
							// objectType/objectId/content/resourceId

							int length = StorageServiceFactory.getService().read(response.getOutputStream(), object.getIconId(), (RestBaseResource) object);
							response.setContentLength(length);
							return true;
						}
					}
					else
					{
						jsonFilters.add(new AttributeFilter(rd.getForgeignKey(), Constants.STRING, rd.getParentResourceId(), Constants.SEARCH_OPERATOR_EQ));
					}
				}
				
				Class<?> objectClass = ClassUtil.getClass(resourceName);
				if (objectClass != null)
				{
					if (resourceId == null || resourceId.length() == 0 || resourceId.equals("list") )
					{
						QueryMetaData qmd = new QueryBuilder().setLimit(pageSize)
							.setObjectType(resourceName)
							.setOffset(offset)
							.setOrderBy(orderBy)
							.setQuery(queryString)
							.setFilters(jsonFilters)
							.setRequestFacets(facets)
							.enableFacet(true)
							.create();
						SearchHits hits = pm.search(qmd, objectClass);
						response.getWriter().write(writer.toString(hits).toString());
					}
					else
					{
						IdObject object = (IdObject) pm.getObjectById(resourceId, objectClass);
						if (object != null)
						{
							response.getWriter().write(writer.toString(object).toString());
						}
						else
						{
							throw new RestfulException(404, "Object not found", resourceId + " " + objectClass);
						}
					}
				}
				else
				{
					throw new RestfulException(401, "Failed to load resource" + resourceName, "GetService");
				}
			}
			catch (SearchException e)
			{
				throw new RestfulException(401, "Failed to query", e.getMessage());
			}
		}

		return true;
	}
}
