package org.sixstreams.rest;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.util.ContextFactory;

public class RestfulServlet extends HttpServlet
{
	protected static Logger sLogger = Logger.getLogger(RestfulServlet.class.getName());
	public void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	public void doTrace(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	public void doHead(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	public void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}
 
	public void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		dispatch(request, response);
	}

	private void dispatch(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		SearchContext ctx = ContextFactory.getSearchContext();
		try
		{
			response.setCharacterEncoding("UTF-8");
			if (SecurityService.getService().performService(request, response))
			{
				RestRequestDispatcher restManager = new RestRequestDispatcher();
				if (restManager.processRequest(request, response))
				{
					return;
				}
			}
		}
		catch(RestfulException e)
		{
			response.setContentType("application/json");
			response.setStatus(e.getCode());
			sLogger.log(Level.INFO, "Failed to serve the request " + e.toString());
			try
			{
				response.getWriter().write(e.toString());
			}
			catch(java.lang.IllegalStateException e1)
			{
				response.getOutputStream().write(e.toString().getBytes());
			}
			catch (IOException e1)
			{
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		catch(Throwable t)
		{
			response.setContentType("application/json");
			RestfulException e = new RestfulException(500, t.getLocalizedMessage(), "Servlet");
			sLogger.log(Level.SEVERE, "Failed to serve the request ", t);
			 
			response.setStatus(e.getCode());
			try
			{
				response.getWriter().write(e.toString());
			}
			catch(java.lang.IllegalStateException e1)
			{
				response.getOutputStream().write(e.toString().getBytes());
			}
			catch (IOException e1)
			{
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		finally
		{
			ctx.release();
		}
	}
}
