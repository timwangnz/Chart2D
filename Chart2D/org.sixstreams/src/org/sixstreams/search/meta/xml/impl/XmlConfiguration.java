package org.sixstreams.search.meta.xml.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.sixstreams.Constants;
import org.sixstreams.search.RuntimeSearchException;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.crawl.scheduler.Schedule;
import org.sixstreams.search.data.java.SearchableDataObject;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.meta.Configurable;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.MetaEngineInstance;
import org.sixstreams.search.meta.ObjectExtension;
import org.sixstreams.search.meta.SearchEngineType;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;


public class XmlConfiguration
   implements Configurable
{
   private static long UNIQUE_ID_SEED = System.currentTimeMillis();
   public final static String CONFIG_FILE_LOCATION = "org.sixstreams.search.meta.xml.impl.location";
   
   private static Map<String, ObjectExtension> objectExtension = new Hashtable<String, ObjectExtension>();

   private static List<String> customProperties = Arrays.asList(new String[]
         { "org.sixstreams.search.apps.connection.name" });

   public static Map<String, String> getCustomProperties(SearchableObject so)
   {
      Map<String, String> properties = so.getProperties();
      Map<String, String> newProperties = new HashMap<String, String>();
      for (String key: customProperties)
      {
         newProperties.put(key, properties.get(key));
      }
      return newProperties;
   }

   public void invalidateCacheItem(String key, Object object)
   {

   }

   public ObjectExtension getObjectExtension(SearchableObject object)
   {
      String cacheKey = object.getSearchEngineInstanceId() + ":" + object.getId();
      ObjectExtension obj = objectExtension.get(cacheKey);
      if (obj == null)
      {
         obj = new ObjectExtension(object);
         objectExtension.put(cacheKey, obj);
      }
      return obj;
   }

   public void synchEngine(long eid)
   {

   }

   public void savePassword(long eid, String username, byte[] password)
   {

   }

   //this constructor should only be used by MetaDataManager, you should not
   //manually create this object

   public XmlConfiguration()
   {

   }

   public Schedule getSchedule(long objectId)
   {

      for (Schedule obj: this.getSchedules())
      {
         if (objectId == Long.valueOf(obj.getId()))
         {
            return obj;
         }
      }
      return null;
   }

   public SearchableObject getSearchableObject(long objectId)
   {
      for (SearchableObject obj: getSearchableObjects())
      {
         if (objectId == Long.valueOf(obj.getId()))
         {
            return obj;
         }
      }
      return null;
   }

   public MetaEngineInstance getEngineInstance(long objectId)
   {
      for (MetaEngineInstance obj: this.getEngineInstances())
      {
         if (objectId == Long.valueOf(obj.getId()))
         {
            return obj;
         }
      }
      return null;
   }

   public SearchableGroup getSearchableGroup(long objectId)
   {
      for (SearchableGroup obj: this.getSearchableGroups())
      {
         if (objectId == Long.valueOf(obj.getId()))
         {
            return obj;
         }
      }
      return null;
   }

   //===========================================================
   // Helpers Methods
   //===========================================================

   /* ---------------------------- */

   public List<SearchableObject> getSearchableObjects()
   {
      if (searchableObjects == null)
      {
         init();
      }
      return searchableObjects;
   }

   public List<SearchableObject> getUnassignedSearchableObjects()
   {
      List<SearchableObject> unassigned = new ArrayList<SearchableObject>();
      for (SearchableObject so: getSearchableObjects())
      {
         if (so.getSearchEngineInstanceId() == -1)
         {
            unassigned.add(so);
         }
      }
      return unassigned;
   }

   public List<SearchableGroup> getSearchableGroups()
   {
      if (searchableGroups == null)
      {
         init();
      }

      return searchableGroups;
   }

   public HashMap<String, String> getEngineParameters(long engineInstId)
   {
      MetaEngineInstance ei = getEngineInstance(engineInstId);
      if (ei == null)
      {
         return new HashMap<String, String>();
      }
      return new HashMap<String, String>(ei.getParameters());
   }

   public List<MetaEngineInstance> getEngineInstances()
   {
      if (engineInstances == null)
      {
         init();
      }
      return engineInstances;
   }

   public List<MetaEngineInstance> getEngineInstances(long engineTypeId)
   {
      List<MetaEngineInstance> engines = new ArrayList<MetaEngineInstance>();
      for (MetaEngineInstance engine: getEngineInstances())
      {
         if (engine.getEngineTypeId() == engineTypeId)
         {
            engines.add(engine);
         }
      }
      return engines;
   }

   public List<SearchEngineType> getSearchEngineTypes()
   {
      if (searchEngineTypes == null)
      {
         init();
      }
      return searchEngineTypes;
   }


   public List<SearchableGroup> getSearchableGroups(long engineInstId)
   {
      List<SearchableGroup> groups = new ArrayList<SearchableGroup>();
      SearchContext ctx = ContextFactory.getSearchContext();
      for (SearchableGroup g: getSearchableGroups())
      {
         if (g.getEngineInstanceId() == engineInstId)
         {
            
               groups.add(g);
        
         }
      }
      return groups;
   }

   public SearchableGroup getSearchableGroup(long engineInstId, String qName)
   {
      for (SearchableGroup group: getSearchableGroups(engineInstId))
      {
         if (group.getName().equals(qName))
         {
            return group;
         }
      }
      return null;
   }


   public SearchableObject getSearchableObject(long engineInstId, String voName)
   {
      for (SearchableObject so: getSearchableObjects())
      {
         if (voName.equals(so.getName()) && so.getSearchEngineInstanceId() == engineInstId)
         {
            return so;
         }
      }
      if (engineInstId == -1)
      {
         synchronized (searchableObjects)
         {
            Class<?> clazz = ClassUtil.getClass(voName);
            if (clazz != null)
            {
               if (clazz.getAnnotation(Searchable.class) != null)
               {
                  SearchableObject object =
                     createSearchableObject(engineInstId, voName, SearchableDataObject.class.getName());
                  if (object != null)
                  {
                     searchableObjects.add(object);
                  }
                  return object;
               }
               else
               {
            	   throw new RuntimeException("Object is not searchable " + voName);
               }
            }
         }
      }
      return null;
   }

   public SearchableObject registerSearchableObject(String name, String className)
   {
      //load the object
      for (SearchableObject obj: searchableObjects)
      {
         if (name.equals(obj.getName()) && obj.getSearchEngineInstanceId() == Constants.INVALID_ENGINE_INST_ID)
         {
            return obj;
         }
      }

      SearchableObject obj = createSearchableObject(Constants.INVALID_ENGINE_INST_ID, name, className);
      if (obj == null)
      {
         return null;
      }

      searchableObjects.add(obj);
      return obj;
   }

   public void removeRegisterSearchableObject(String objectName, String className)
   {
      SearchableObject object = null;
      for (SearchableObject obj: this.getUnassignedSearchableObjects())
      {
         if (obj.getName().equals(objectName))
         {
            object = obj;
         }
      }
      if (object != null)
      {
         searchableObjects.remove(object);
      }
      else
      {
         throw new RuntimeException("Failed to remove searchable object " + objectName +
                                    ", Either object does not exist, or it is used!");
      }
   }

   public SearchableObject createSearchableObject(long eid, String name, String className)
   {
      SearchableObject object = null;
      try
      {
         object = (SearchableObject) ClassUtil.create(className);
         object.setName(name);
         object.initializeConfig();
      }
      catch (Exception e)
      {
         return null;
      }

      if (object != null)
      {
         object.setId("" + getNextId());
         object.setLastTimeCrawled(null);
         object.setSearchEngineInstanceId(eid);
      }
      return object;
   }

   public MetaEngineInstance createEngineInstance(long engineTypeId, String name)
   {
      for (MetaEngineInstance engine: getEngineInstances())
      {
         if (engine.getName().equals(name) && engine.getEngineTypeId() == engineTypeId)
         {
            throw new RuntimeSearchException("Engine named " + name + " of type " + engineTypeId + " already exists!");
         }
      }

      SearchEngineType engineType = getSearchEngineType(engineTypeId);
      MetaEngineInstance engine = engineType.createEngine(getNextId(), name);

      getEngineInstances().add(engine);

      return engine;
   }


   private SearchEngineType getSearchEngineType(long id)
   {
      for (SearchEngineType engineType: getSearchEngineTypes())
      {
         if (id == engineType.getId())
         {
            return engineType;
         }
      }
      throw new RuntimeException("Can not find engine type " + id);
   }


   public Schedule createSchedule(long engineId, String name)
   {
      List<Schedule> schedules = getSchedules();
      for (Schedule schd: schedules)
      {
         if (schd.getName().equals(name))
         {
            throw new RuntimeException("Schd " + name + " already exists!");
         }
      }

      Schedule schd = new Schedule();

      schd.setName(name);
      schd.setEngineInstanceId(engineId);
      schd.setId("" + getNextId());
      schd.setDeployed(true);
      schedules.add(schd);
      return schd;
   }

   public SearchableGroup createSearchableGroup(long engineId, String name)
   {
      SearchableGroup group = getSearchableGroup(engineId, name);
      if (group != null)
      {
         throw new RuntimeException("Group " + name + " already exists");
      }
      group = new SearchableGroup(name);
      group.setEngineInstanceId(engineId);
      group.setId("" + System.currentTimeMillis());
      group.setDeployed(true);
      getSearchableGroups().add(group);
      return group;
   }

   public Schedule addToSchedule(SearchableObject object, Schedule schedule)
   {
      schedule.addObject(object.getName());
      return schedule;
   }

   public void removeObjectFromEngine(SearchableObject obj, long eid)
   {
      if (eid == -1)
      {
         return;
      }

      SearchEngine se = MetaDataManager.getSearchEngine(eid);
      SearchContext ctx = ContextFactory.getSearchContext();
      ctx.setSearchableObject(obj);
      se.getIndexer().deleteIndex();
      obj.setSearchEngineInstanceId(Constants.INVALID_ENGINE_INST_ID);
   }

   public Schedule removeFromSchedule(SearchableObject object, Schedule schedule)
   {
      schedule.removeObject(object.getName());
      return schedule;
   }

   public SearchableGroup addToGroup(SearchableObject object, SearchableGroup group)
   {
      if (object == null)
      {
         return group;
      }
      for (SearchableObject obj: group.getSearchableObjects())
      {
         if (obj.getId().equals(object.getId()))
         {
            return group; //already in the group
         }
      }
      if (!group.getObjectNames().contains(object.getName()))
      {
         group.addSearchableObject(object.getName());
      }
      return group;
   }

   public SearchableGroup removeFromGroup(SearchableObject object, SearchableGroup group)
   {
      group.getObjectNames().remove(object.getName());
      return group;
   }

   public boolean deleteEngineInstance(long eid)
   {
      MetaEngineInstance engine = getEngineInstance(eid);
      for (SearchableObject obj: getSearchableObjects(engine.getId()))
      {
         if (searchableObjects.contains(obj))
         {
            searchableObjects.remove(obj);
         }
      }
      for (SearchableGroup group: engine.getSearchableGroups())
      {
         if (searchableGroups.contains(group))
         {
            searchableGroups.remove(group);
         }
      }

      for (Schedule schd: getSchedules(engine.getId()))
      {
         if (schedules.contains(schd))
         {
            schedules.remove(schd);
         }
      }

      engineInstances.remove(engine);
      return true;
   }

   public boolean deleteSchedule(long eid)
   {
      Schedule schedule = getSchedule(eid);
      schedules.remove(schedule);
      return true;

   }

   public boolean deleteSearchableGroup(long eid)
   {
      SearchableGroup group = getSearchableGroup(eid);
      searchableGroups.remove(group);
      return true;

   }

   public boolean deleteSearchableObject(long id)
   {
      SearchableObject object = getSearchableObject(id);
      if (object != null && searchableObjects != null)
      {
         if (searchableObjects.contains(object))
         {
            searchableObjects.remove(object);
            return true;

         }
      }
      return false;
   }

   public SearchableObject addSearchableObjectToEngineInstance(SearchableObject object, long eid)
   {
      SearchableObject obj = getSearchableObject(eid, object.getName());
      if (obj != null)
      {
         return obj; //does nothing
      }

      if (object.getSearchEngineInstanceId() == Constants.INVALID_ENGINE_INST_ID)
      {
         obj = createSearchableObject(eid, object.getName(), object.getClass().getName());
      }
      else
      {
         obj = object;
         object.setId("" + getNextId());
         object.setLastTimeCrawled(null);
         object.setSearchEngineInstanceId(eid);
      }

      searchableObjects.add(obj);
      return obj;
   }

   public List<SearchableObject> getSearchableObjects(long eid)
   {
      List<SearchableObject> objects = new ArrayList<SearchableObject>();
      for (SearchableObject object: getSearchableObjects())
      {
         if (eid == object.getSearchEngineInstanceId())
         {
            objects.add(object);
         }
      }
      return objects;
   }

   public List<Schedule> getSchedules()
   {
      if (schedules == null)
      {
         init();
      }
      return schedules;
   }

   public List<Schedule> getSchedules(long eid)
   {
      List<Schedule> objects = new ArrayList<Schedule>();
      for (Schedule object: getSchedules())
      {
         if (eid == object.getEngineInstanceId())
         {
            objects.add(object);
         }
      }
      return objects;
   }

   private void init()
   {
      try
      {
         if (!loaded)
         {
            engineInstances = new ArrayList<MetaEngineInstance>();
            searchableObjects = new ArrayList<SearchableObject>();
            searchableGroups = new ArrayList<SearchableGroup>();
            schedules = new ArrayList<Schedule>();
           
            searchEngineTypes = new ArrayList<SearchEngineType>();

            fileHandler.reload();
            loaded = true;

            if (searchEngineTypes.size() == 0)
            {
               addEngineType(3, "Lucene", "org.sixstreams.search.solr.impl.SearchEngineImpl");
            }
         }
      }
      catch (Throwable t)
      {
         throw new RuntimeException("Failed to load configuration", t);
      }
   }

   private void addEngineType(long id, String name, String className)
   {
      SearchEngineType engineType = new SearchEngineType(id);
      engineType.setEngineImplType(className);
      engineType.setName(name);
      engineType.addParameter("INDEX_LOCATION", "/tmp/lucene");
      searchEngineTypes.add(engineType);
   }

   public void save()
   {
      fileHandler.save();
   }

   public void save(Object obj)
   {
      fileHandler.save();
   }

   String getLocation()
   {
      if (filename == null)
      {
         filename = MetaDataManager.getProperty(CONFIG_FILE_LOCATION);
      }
      if (filename == null)
      {
         //throw new RuntimeException("You must specify DAAS parameter in the daas.properties file for " + CONFIG_FILE_LOCATION);
      }
      return filename;
   }

   public void reload()
   {
      try
      {
         loaded = false;
         init();
      }
      catch (Throwable t)
      {
         engineInstances = null;
         searchableObjects = null;
         searchableGroups = null;
         schedules = null;
       
         searchEngineTypes = null;
         throw new RuntimeSearchException("Failed to load configuration", t);
      }
   }

   public void updateCacheItem(String type, Object obj)
   {
      // do nothing
   }

   private long getNextId()
   {
      return UNIQUE_ID_SEED++;
   }

   public void addParameter(String name, Object value)
   {
      parameters.put(name, value);
   }

   public Object getParameter(String name)
   {
      Object value = parameters.get(name);
      if (value == null)
      {
         value = System.getProperty(name);
      }
      return value;
   }

   public Map<String, Object> getParameters()
   {
      return parameters;
   }

   private String filename = null;
   private FileHandler fileHandler = new FileHandler(this);

   private List<MetaEngineInstance> engineInstances = null;
   private List<SearchableObject> searchableObjects = null;
   private List<SearchableGroup> searchableGroups = null;
   private List<SearchEngineType> searchEngineTypes = null;
   private List<Schedule> schedules = null;
  
   private Map<String, Object> parameters = new Hashtable<String, Object>();
   private boolean loaded = false;


}
