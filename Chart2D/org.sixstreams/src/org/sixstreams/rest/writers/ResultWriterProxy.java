package org.sixstreams.rest.writers;

import java.util.List;


public class ResultWriterProxy
   extends ResultWriter
{
   private ResultWriter resultWriter;

   public ResultWriterProxy(String format)
   {
	   resultWriter = new JSONWriter(); 
   }

   public StringBuffer toString(Object object)
   {
      return resultWriter.toString(object);
   }

   public void setExcludingRules(List<String> rules)
   {
      resultWriter.setExcludingRules(rules);
   }
   public void setIncludingRules(List<String> rules)
   {
      resultWriter.setIncludingRules(rules);
   }
   public String getContentType()
   {
      return resultWriter.getContentType();
   }
}
