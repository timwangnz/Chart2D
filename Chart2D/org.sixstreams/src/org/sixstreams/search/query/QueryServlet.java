package org.sixstreams.search.query;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.data.IndexableManager;
import org.sixstreams.search.util.ContextFactory;

public class QueryServlet
   extends HttpServlet
{

   public void init(ServletConfig config)
      throws ServletException
   {
      super.init(config);
   }

   public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException
   {
      doPost(request, response);
   }

   public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException
   {
      SearchContext ctx = ContextFactory.getSearchContext();
      try
      {
         //handles files sent to this server
         ctx.setAttribute("org.sixstreams.search.request.type", "api");
         IndexableManager indexableMgr = new IndexableManager();
         if (indexableMgr.processRequest(request, response))
         {
            return;
         }
      }
      finally
      {
         ctx.release();
      }
   }
}
