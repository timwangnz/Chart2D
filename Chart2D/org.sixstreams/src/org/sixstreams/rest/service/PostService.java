package org.sixstreams.rest.service;
import java.util.Date;
import java.util.List;
import java.util.logging.Level;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.IOUtils;
import org.sixstreams.Constants;
import org.sixstreams.rest.Auditable;
import org.sixstreams.rest.IdObject;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.rest.StorageServiceFactory;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.social.Person;
import org.sixstreams.social.Resource;
import org.sixstreams.social.SocialAction;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * INSERT
 * 
 * Entity http://hostname:port/contextPath/objectType e.g.
 * http://localhost:8080/sixstreams/org.mypacswim.User/test.again@mypacswim.com
 * 
 * method=POST jsonObject
 * 
 * returns json object of given type created with id
 * 
 * 
 * options x-sixstreams-
 * 
 * @author anpwang
 * 
 */
public class PostService extends PutService
{
	public boolean performService(HttpServletRequest request, HttpServletResponse response)
	{
		parseRequest(request, response);
		String resourceName = rd.getResource();		
		if (resourceName == null)
		{
			throw new RestfulException(404, "Resource name is  required", "Create");
		}
		Person person = ContextFactory.getSearchContext().getUser();
		
		if (person == null)
		{
			throw new RestfulException(404, "Must signin to create a resource", "Create");
		}
		
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		if (!isMultipart)
		{
			try
			{
				String contentType = request.getContentType();
				sLogger.info("Is multi part " + isMultipart + " " + contentType);

				if (contentType.contains(Constants.CONTENT_TYPE_JSON))
				{
					String json = IOUtils.toString(request.getInputStream());
					SearchableObject object = MetaDataManager.getSearchableObject(resourceName);
					if (object != null)
					{
						Gson gson = new Gson();
						sLogger.info("Income json" + json);
						IdObject obj = (IdObject) gson.fromJson(json, ClassUtil.getClass(resourceName));
						if (obj == null)
						{
							throw new RestfulException(401, "Failed to create object from data " + resourceName, Constants.ACTION_CREATE);
						}
						obj.setCreatedBy(person.getId());
						
						obj.setCreatedByName(person.getFirstName() + " " + person.getLastName() + "---" + obj.getCreatedBy());
						obj.setDateCreated(new Date());
						obj.setAppId(ContextFactory.getSearchContext().getAppId());
						
						if (obj instanceof SocialAction)
						{
							((SocialAction)obj).preCreate();
						}
						
						PersistenceManager pm = new PersistenceManager();
						pm.insert(obj);
						
						if(obj instanceof Auditable)
						{
							recordActivity(pm, obj, "Create");
						}
						
						response.getWriter().write(writer.toString(obj).toString());
						if (obj instanceof SocialAction)
						{
							((SocialAction)obj).onCreate();
						}
						else
						{
							person.setPoints(person.getPoints() + 10);
							pm.update(person);
						}
						sLogger.info("Object returned" + obj.getId());
					}
					else
					{
						sLogger.severe("Object definition not found " + resourceName);
						throw new RestfulException(404, "Object definition not found " + resourceName, Constants.ACTION_CREATE);
					}
				}
			}
			catch (RestfulException re)
			{
				throw re;
			}
			catch (Exception e)
			{
				sLogger.log(Level.SEVERE, "Failed to create json item", e);
				throw new RestfulException(500, "Failed to create json item", Constants.ACTION_CREATE);
			}
		}
		else
		{
			try
			{
				// Create a factory for disk-based file items
				FileItemFactory factory = new DiskFileItemFactory();
				// Create a new file upload handler
				ServletFileUpload upload = new ServletFileUpload(factory);
				// Parse the request
				@SuppressWarnings("unchecked")
				List<FileItem> items = upload.parseRequest(request);
				if (items == null || items.size() == 0)
				{
					throw new RestfulException(400, "No data received in the upload request", Constants.ACTION_UPLOAD);
				}

				Resource metadata = null;
				for (FileItem item : items)
				{
					if (item.getContentType().equals(Constants.CONTENT_TYPE_JSON))
					{
						Gson gson = new GsonBuilder().setDateFormat(Constants.DATE_TIME_FORMAT).create();
						metadata = (Resource) gson.fromJson(item.getString(), ClassUtil.getClass(resourceName));
					}
				}

				for (FileItem item : items)
				{
					if (item.getContentType() != null && !item.getContentType().contains(Constants.CONTENT_TYPE_JSON))
					{
						try
						{
							if (item.getFieldName().contains(Constants.SEARCH_ICON))
							{
								StorageServiceFactory.getService().save(item.getInputStream(), metadata.getIconId(), item.getContentType(), metadata);
							}
							else
							{
								StorageServiceFactory.getService().save(item.getInputStream(), metadata.getId(), item.getContentType(), metadata);
							}
						}
						catch (Exception e)
						{
							throw new RestfulException(500, "Failed to save uploaded item", Constants.ACTION_UPLOAD);
						}
					}
				}
				if (metadata != null)
				{
					metadata.setContentUrl(metadata.getClass().getName() + Constants.PATH_SEPARATOR + metadata.getId() + Constants.PATH_SEPARATOR + Constants.SEARCH_CONTENT);
					metadata.setIconUrl(metadata.getClass().getName() + Constants.PATH_SEPARATOR + metadata.getId() + Constants.PATH_SEPARATOR + Constants.SEARCH_ICON);
					metadata.setCreatedBy(person.getId());
					metadata.setDateCreated(new Date());
					PersistenceManager pm = new PersistenceManager();
					pm.insert(metadata);
					recordActivity(pm, metadata, Constants.ACTION_CREATE);
				}
				response.getWriter().write(writer.toString(metadata).toString());
			}
			catch (RestfulException re)
			{
				throw re;
			}
			catch (Exception e)
			{
				sLogger.log(Level.SEVERE, "Failed to process upload items", e);
				throw new RestfulException(500, "Failed to process upload items", Constants.ACTION_UPLOAD);
			}
		}

		return true;
	}
}
