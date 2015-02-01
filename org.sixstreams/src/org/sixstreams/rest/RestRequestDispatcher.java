package org.sixstreams.rest;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.rest.service.DeleteService;
import org.sixstreams.rest.service.GetService;
import org.sixstreams.rest.service.PostService;
import org.sixstreams.rest.service.PutService;

/**
 * Restful service with API defined as following get
 * objectName/?query=filter&fields=name,descriptiom retrieves a collection of
 * object by objectName
 * 
 * get objectName/id/?fields=name, description
 * 
 * put - update objectName/id/?fields=name, description payload
 * 
 * delete objectName/id objectName/?query=filter
 * 
 * post - create objectName payload
 * 
 * get definition/objectName
 * 
 */
public class RestRequestDispatcher
{
	private ActionService getActionService(HttpServletRequest request)
	{
		if (request.getMethod().equalsIgnoreCase("PUT"))
		{
			return new PutService();
		}
		else if (request.getMethod().equalsIgnoreCase("DELETE"))
		{
			return new DeleteService();
		}
		else if (request.getMethod().equalsIgnoreCase("POST"))
		{
			return new PostService();
		}
		else if (request.getMethod().equalsIgnoreCase("GET"))
		{
			return new GetService();
		}
		return new DefaultService();
	}

	protected Object getError(Throwable t, String requestUri)
	{
		Map<String, String> error = new HashMap<String, String>();
		error.put("error", t.getMessage());
		error.put("requestId", "" + requestUri);
		return error;
	}

	public boolean processRequest(HttpServletRequest request, HttpServletResponse response)
	{
		ActionService service = getActionService(request);
		return service.performService(request, response);
	}

}
