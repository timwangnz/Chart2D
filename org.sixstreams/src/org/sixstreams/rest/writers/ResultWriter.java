package org.sixstreams.rest.writers;

import java.util.List;

public abstract class ResultWriter
{
   List<String> excludingAttributes;
   List<String> includingAttributes;

   abstract public String getContentType();

   abstract public StringBuffer toString(Object object);
   public void setIncludingRules(List<String> rules)
   {
      this.includingAttributes = rules;
   }

   public List<String> getIncludingRules()
   {
      return includingAttributes;
   }

   public void setExcludingRules(List<String> rules)
   {
      this.excludingAttributes = rules;
   }

   public List<String> getExcludingRules()
   {
      return excludingAttributes;
   }

   public boolean isAttributeRendered(String name)
   {
      if (excludingAttributes == null || excludingAttributes.isEmpty() || name == null)
      {
         return true;
      }
      //only render if name is one  the list
      return excludingAttributes.contains(name);
   }
}
