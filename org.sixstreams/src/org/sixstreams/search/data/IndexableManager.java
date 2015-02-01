package org.sixstreams.search.data;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class IndexableManager
{
   public static final String ACTION_KEY = "org.sixstreams.indexable.action";
   public static final String CONTENT_KEY = "org.sixstreams.indexable.content";
   public static final String ACTION_UPLOAD = "upload";

   public boolean processRequest(HttpServletRequest request, HttpServletResponse response)
      throws IOException
   {
      String action = request.getHeader(ACTION_KEY);
      if (ACTION_UPLOAD.equals(action))
      {
         String xml = request.getParameter(CONTENT_KEY);
         if (xml == null || xml.length() == 0)
         {
            return false;
         }
         PersistenceManager handler = new PersistenceManager();
         try
         {
            handler.indexDocuments(xml);
            return true;
         }
         catch (UnsupportedOperationException e)
         {
            return false;
         }
      }
      return false;
   }
}
