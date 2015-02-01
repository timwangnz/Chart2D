package org.sixstreams.search.meta;

import java.io.Serializable;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.util.ContextFactory;


public class MetaEngineInstance
   implements Serializable
{
   public long getId()
   {
      return id;
   }

   public Map<String, String> getParameters()
   {
      return parameters;
   }

   public void setParameters(Map<String, String> parameters)
   {
      this.parameters = parameters;
   }

   public void addParameter(String name, String value)
   {
      if (parameters == null)
      {
         parameters = new HashMap<String, String>();
      }
      parameters.put(name, value);
   }

   public Collection<SearchableGroup> getSearchableGroups()
   {
      return MetaDataManager.getSearchableObjectGroups(id);
   }

   public SearchableObject getSearchableObject(String name)
   {
      return MetaDataManager.getSearchableObject(id, name);
   }

   public String getEngineType()
   {
      return engineType;
   }

   public void setId(long id)
   {
      this.id = id;
   }

   public void setEngineType(String engineType)
   {
      this.engineType = engineType;
   }

   public void setName(String name)
   {
      this.name = name;
   }

   public String getName()
   {
      return name;
   }

   public String getDisplayName()
   {
      SearchContext ctx = ContextFactory.getSearchContext();
      return getName();
   }

   public void setEngineTypeId(long id)
   {
      this.engineTypeId = id;
   }

   public long getEngineTypeId()
   {
      return engineTypeId;
   }

   public void setComponentId(long componentId)
   {
      this.componentId = componentId;
   }

   public long getComponentId()
   {
      return componentId;
   }

   private long id;
   private String name;
   private String engineType;
   private long engineTypeId;
   private long componentId;
   private Map<String, String> parameters = new HashMap<String, String>();
}
