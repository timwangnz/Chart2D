package org.sixstreams.search.meta;

import java.util.List;
import java.util.Map;

import org.sixstreams.search.crawl.scheduler.Schedule;

public interface Configurable
   extends Configuration
{
   List<SearchableObject> getUnassignedSearchableObjects();

   /** Returns all engine types supported by this configuration store */
   List<SearchEngineType> getSearchEngineTypes();

   /**
    *Returns a list of schedules by engine id
    * @return
    */
   List<Schedule> getSchedules(long engineInstId);

   /** Sync engine instance with search engine istallaction. This operation
    * might be search engien specific */
   void synchEngine(long eid);

   /**
    * Adds searchable object to an engine instance
    * @param object the searchable object to be added
    * @param engineInstId id of the search engine instance.
    */
   SearchableObject addSearchableObjectToEngineInstance(SearchableObject object, long engineInstId);

   ObjectExtension getObjectExtension(SearchableObject object);

   /**
    * Returns searchable objects registered against an search engine
    * @param engineInstId id of the search engine instnace.
    * @return list of searchable objects.
    */
   List<SearchableObject> getSearchableObjects(long engineInstId);

   /**
    * Returns a searchable object by its id.
    * @param objectId id of the searchable object.
    * @return SearchableObject if found, null if not.
    */
   SearchableObject getSearchableObject(long objectId);

   /**
    * Returns a schedule by its id. If not found, null is returned;
    * @param scheduleId id of the schedule.
    * @return Schedule if found and null if not.
    */
   Schedule getSchedule(long scheduleId);

   /**
    * Returns a searchable group by its id, if not found, null is returned;
    * @param objectId id of the searchable group
    * @return SearchableGroup if found, null if not.
    */
   SearchableGroup getSearchableGroup(long objectId);

   /**
    * Returns an engine instance by its id. If not found, null is returned.
    * @param objectId id of the search engine.
    * @return MetaEngineInstance if found or null if not.
    */
   MetaEngineInstance getEngineInstance(long objectId);

   /**
    * Delete searchable object from the configuration
    * @param objectId id of the searchable object to be deleted.
    * @return true if succeed.
    */
   boolean deleteSearchableObject(long objectId);

   /**
    * Delete searchable group from the configuration
    * @param groupId id of the searchable object to be deleted.
    * @return true if succeed.
    */
   boolean deleteSearchableGroup(long groupId);

   /**
    * Delete schedule from the configuration
    * @param scheduleId id of the searchable object to be deleted.
    * @return true if succeed.
    */
   boolean deleteSchedule(long scheduleId);

   /**
    * Delete engine instnace from the configuration
    * @param engineInstId id of the searchable object to be deleted.
    * @return true if succeed.
    */
   boolean deleteEngineInstance(long engineInstId);

   /**
    * Saves password to the configuration
    * @param engineInstId id of the engine instance
    * @param username the username to which the password is for
    * @param password password to be saved
    */
   void savePassword(long engineInstId, String username, byte[] password);

   /**
    * register a searchable object
    * @param objectName the name of the object.
    * @param className class name of the object, could be VO name.
    * @return returns the object registed if succeed.
    */
   SearchableObject registerSearchableObject(String objectName, String className);

   /**
    * remove a registered searchable object
    * @param objectName the name of the object.
    * @param className class name of the object, could be VO name.
    */
   void removeRegisterSearchableObject(String objectName, String className);

   /**
    * Create engine instance of an engien type
    * @param engineType type of the search engine to be created
    * @param name of the engine instnace.
    * @return the engine instance created if succeed. If not, null is returned.
    */
   MetaEngineInstance createEngineInstance(long engineType, String name);

   /**
    * Creates a schedule in the configuration store.
    * @param engineInstId search engine instance this schedule will be create within.
    * @param name schedule name.
    * @return the schedule created if succeed. Or null is returned.
    */
   Schedule createSchedule(long engineInstId, String name);

   /**
    * Creates a searchable group in the configuration store.
    * @param engineInstId search engine instance this schedule will be create within.
    * @param name schedule name.
    * @return the schedule created if succeed. Or null is returned.
    */
   SearchableGroup createSearchableGroup(long engineInstId, String name);

   /**
    * Addes an object to the schedule
    * @param object the object to add the schedule.
    * @param schedule the schedule object to be added.
    * @return the schedule itself.
    */
   Schedule addToSchedule(SearchableObject object, Schedule schedule);

   /**
    * Removes an object to a schedule
    * @param object the object to be removed from the schedule.
    * @param schedule the schedule from which the object is removed.
    * @return the schedule itself.
    */
   Schedule removeFromSchedule(SearchableObject object, Schedule schedule);

   /**
    * Addes an object to the group
    * @param object the object to add the group.
    * @param group the group object to be added.
    * @return the group itself.
    */
   SearchableGroup addToGroup(SearchableObject object, SearchableGroup group);

   /**
    * Removes an object to a group
    * @param object the object to be removed from the group.
    * @param group the group from which the object is removed.
    * @return the group itself.
    */
   SearchableGroup removeFromGroup(SearchableObject object, SearchableGroup group);

   /**
    * Saves the entire store.
    */
   void save(Object object);

   /**
    * Saves the entire store.
    */
   void save();

   /**
    *Adds a configuration parameter.
    * @param name the name of the configuration parameter.
    * @param value the value of the configuarion paameter. If a parameter with
    * the same name already exists, its value will be updated.
    */
   void addParameter(String name, Object value);

   /**
    * Returns a list of parameters
    */
   Map<String, Object> getParameters();
}
