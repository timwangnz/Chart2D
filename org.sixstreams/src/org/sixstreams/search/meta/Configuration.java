package org.sixstreams.search.meta;

import java.util.List;
import java.util.Map;

public interface Configuration
{
   /**
    * Returns all search engine instances, regardless engine types
    * @return a list of search engine instances available.
    */
   List<MetaEngineInstance> getEngineInstances();

   /**
    * Returns all search engine instances of a given type by type id
    *
    * @param engineTypeId - engine type id.
    *
    * If engine type with engineTypeId doesn't exist, throws RuntimeMetadataException.
    * @return a list of search engine instances available.
    */
   List<MetaEngineInstance> getEngineInstances(long engineTypeId);

   /**
    * Returns engine parameters in a hashmap for a given engine
    * instance.
    * @param engineId - the engine instance id.
    *
    * If engine with engineId doesn't exist, throws RuntimeMetadataException.
    * @return Hashmap configration parameter
    */
   Map<String, String> getEngineParameters(long engineId);

   /**
    * Returns a searchable group for a given search engine instance, by name.
    * @param engineId - The identification of the engine instance.
    * @param name - The name of the searchable group.
    *
    * If engine with engineId doesn't exist, or name doesn't exist, throws RuntimeMetadataException.
    * @return a searchable group. Null if not found.
    */
   SearchableGroup getSearchableGroup(long engineId, String name);

   /**
    * Returns a searchable object for a given search engine instance by class
    * name.
    * @param engineId The identification of the engine instance.
    * @param name The class name of the searchable object.
    *
    * If engine with engineId, or name doesn't exist, throws RuntimeMetadataException.
    * @return a searchable object, null if not found.
    */
   SearchableObject getSearchableObject(long engineId, String name);

   /**
    * Returns a list of searchable groups for a given search engine instance.
    * @param engineId The indentification of the engine instance.
    *
    * If engine with engineId doesn't exist, throws RuntimeMetadataException.
    * @return a list of searchable groups, empty if not found.
    */
   List<SearchableGroup> getSearchableGroups(long engineId);

   /**
    * Request a reload the configuration. Implementation should reload the
    * objects from persistent storage.
    */
   void reload();

   /**
    * Notifies the config that an object has changed.
    * @param type - the type of object (SearchableObject, etc).
    * @param obj - the object
    */
   void updateCacheItem(String type, Object obj);

   /**
    * Invalidates the cached item.
    * @param type - the type of object (SearchableObject, etc).
    * @param obj - the object
    */
   void invalidateCacheItem(String type, Object obj);
}
