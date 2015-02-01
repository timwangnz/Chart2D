package org.sixstreams.search.meta;

import java.io.IOException;
import java.io.Serializable;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.res.DefaultBundle;
import org.sixstreams.search.util.ContextFactory;


/**
 * The <code>SearchableGroup</code> represents search related
 * meta data for a business object.
 */

public class SearchableGroup
   implements Serializable
{
   protected static Logger sLogger = Logger.getLogger(SearchableGroup.class.getName());

   private String name;
   private List<String> objectNames;
   private transient List<SearchableObject> searchableObjects;
   private String mSearchEngineReference;

   private long engineInstanceId = -1;

   private String id;
   private String scope;
   private boolean deployed;

   /**
    * Constructs searchable group from a name
    * @param name
    */
   public SearchableGroup(String name)
   {
      this.name = name;
      objectNames = new ArrayList<String>();
      searchableObjects = new ArrayList<SearchableObject>();
   }

   /**
    * Get a list of searchable objects for this searchable group
    * @return list of searchable objects.
    */
   public List<SearchableObject> getSearchableObjects()
   {
      ArrayList<SearchableObject> objects = new ArrayList<SearchableObject>();

      // add all objects that were added explicitly
      objects.addAll(searchableObjects);


      for (String fullName: objectNames)
      {
         SearchableObject so = getSearchableObject(fullName);

         if (so != null)
         {
            objects.add(so);
         }
      }
      return objects;
   }

   /**
    * Associate a searchable object with this searchable group
    * @param so
    *
    * @deprecated if this is used, these objects are not serialized.
    */
   @Deprecated
   public void addSearchableObject(SearchableObject so)
   {
      searchableObjects.add(so);
   }

   /**
    * Associate a searchable object with this searchable group
    * @param so searchable object
    */
   public void addSearchableObject(String fullName)
   {
      objectNames.add(fullName);
   }

   public void clearSearchObjects()
   {
      objectNames.clear();
      searchableObjects.clear();
   }

   /**
    * Returns named field definition.
    * @param fieldName this is the column name (alias name) of the field.
    * @return a field definition, null if not found.
    */
   public AttributeDefinition getAttrDef(String fieldName)
   {
      AttributeDefinition fieldDef = null;
      List<SearchableObject> objects = getSearchableObjects();

      for (int i = 0; i < objects.size(); i++)
      {
         SearchableObject so = objects.get(i);
         fieldDef = so.getDocumentDef().getAttributeDef(fieldName);
         if (fieldDef != null)
         {
            break;
         }
      }
      return fieldDef;

   }

   /**
    * Returns named field definition.
    * @param fieldName this is the attribute name (alias name) of the field.
    * @return a field definition, null if not found.
    */

   public AttributeDefinition getAttrByName(String fieldName)
   {
      AttributeDefinition attrDef = null;
      List<SearchableObject> objects = getSearchableObjects();

      for (int i = 0; i < objects.size(); i++)
      {
         SearchableObject so = objects.get(i);
         attrDef = so.getDocumentDef().getAttrDefByName(fieldName);
         if (attrDef != null)
         {
            break;
         }
      }
      return attrDef;

   }

   /**
    * Get the name of this searchable group
    * @return name
    */
   public String getName()
   {
      return name;
   }

   public void setEngineInstanceId(long seiId)
   {
      engineInstanceId = seiId;
   }

   public long getEngineInstanceId()
   {
      return engineInstanceId;
   }

   /**
    * Sets the reference value for this definition in a search engine.
    * @param seReference search engine reference
    */
   public void setSearchEngineReference(String seReference)
   {
      mSearchEngineReference = seReference;
   }

   /**
    * Get the search engine reference for this searchable group
    * @return search enginer reference
    */
   public String getSearchEngineReference()
   {
      return mSearchEngineReference;
   }

   /**
    * Returns the display name of this searchable group
    * @return displayName
    */
   public String getDisplayName()
   {
      SearchContext ctx = ContextFactory.getSearchContext();
      return getName();
   }

   /**
    * Sets mId for this group.
    * @param id the new Id
    */
   public void setId(String id)
   {
      this.id = id;
   }

   /**
    * Returns mId attribute for this group.
    * @return group mId.
    */
   public String getId()
   {
      return id;
   }

   /**
    * set the scope of the search group
    * @param scope a scope string
    */
   public void setScope(String scope)
   {
      this.scope = scope;
   }

   /**
    * get the scope of the search group
    * @return a scope string
    */
   public String getScope()
   {
      return scope;
   }

   /**
    * Get the names of searchable objects.
    * @return a list of searchable object names.
    */
   public List<String> getObjectNames()
   {
      return objectNames;
   }

   /**
    * Get the searchable object from MetaDataManager.
    * @param objectName
    * @return searchable object and null if no object is found by the name.
    */
   private SearchableObject getSearchableObject(String objectName)
   {
      SearchableObject so = null;
      try
      {
         so = MetaDataManager.getSearchableObject(engineInstanceId, objectName);
      }
      catch (Throwable t)
      {
         if (sLogger.isLoggable(Level.WARNING))
         {
            String[] params = new String[]
               { objectName, getName(), String.valueOf(engineInstanceId) };
            sLogger.log(Level.WARNING, DefaultBundle.getResource(DefaultBundle.SEARCHGROUP_LOAD_SO_FAILED, params), t);
         }
      }
      return so;
   }

   /**
    * Custom serialization routine.
    * @param out
    * @throws IOException
    */
   private void writeObject(java.io.ObjectOutputStream out)
      throws IOException
   {
      out.defaultWriteObject();
   }

   /**
    * Custom deserialization routine.
    * @param in
    * @throws IOException
    * @throws ClassNotFoundException
    */
   private void readObject(java.io.ObjectInputStream in)
      throws IOException, ClassNotFoundException
   {
      in.defaultReadObject();

      // create an empty array
      searchableObjects = new ArrayList<SearchableObject>();
   }

   /**
    * @deprecated, use setDeployed instead
    * @param deployed
    */
   public void setIsDeployed(boolean deployed)
   {
      this.deployed = deployed;
   }

   /**
    * Returns deploy status of this group.
    * @param deployed
    */
   public void setDeployed(boolean deployed)
   {
      this.deployed = deployed;
   }

   public boolean isDeployed()
   {
      return deployed;
   }
}
