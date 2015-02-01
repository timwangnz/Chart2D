package org.sixstreams.search.query;

import java.io.Serializable;

import org.sixstreams.search.util.ContextFactory;

public class SearchGroup
   implements Serializable
{
   private String name;
   private long engineInstanceId = -1;


   /**
    * a constructor
    * @param name  a search group name string
    * @param seiId an id of the containing search engine instance
    */
   public SearchGroup(String name, long seiId)
   {
      this.name = name;
      this.engineInstanceId = seiId;
   }

   /**
    * Returns the mName of the search group
    * @return String mName
    */
   public String getName()
   {
      return this.name;
   }

   /**
    * Returns the display mName of the search group
    * @return String display mName
    */
   public String getDisplayName()
   {
      return getName();
   }


   /**
    * Returns the search engine instance id of the search group
    * @return searchEngineInstanceId
    */
   public long getSearchEngineInstanceId()
   {
      return this.engineInstanceId;
   }


   public void setSearchEngineInstanceId(long engineInstanceId)
   {
      this.engineInstanceId = engineInstanceId;
   }


   /**
    * Equals only if name and engine instance id are the same.
    * @param group The group to be tested.
    * @return ture if two groups equal.
    */
   public boolean isEqual(SearchGroup group)
   {
      if (this == group)
      {
         return true;
      }

      if (group == null)
      {
         return false;
      }

      if (engineInstanceId != group.engineInstanceId)
      {
         return false;
      }

      if (!(name == null? group.name == null: name.equals(group.name)))
      {
         return false;
      }

      return true;
   }
}
