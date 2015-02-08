package org.sixstreams.search.meta;

import java.io.IOException;
import java.io.InputStream;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Logger;

import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.meta.xml.impl.XmlConfiguration;

//import org.sixstreams.search.solr.SearchEngineImpl;
import org.sixstreams.search.util.ClassUtil;

/**
 * <code>MetaDataManager</code> is responsible for managing meta data stored in
 * meta data repository.
 */
public class MetaDataManager {

    protected static Logger sLogger = Logger.getLogger(MetaDataManager.class.getName());

    public static final long NO_ENGINE_INSTANCE_ID = -1;
    public static final String SECURITY_FLAG = "org.sixstreams.security.disabled";
    public static final String CONFIG_CLASS = "org.sixstreams.search.configuration.class";
    private static final String ENGINE_DEFAULT_CLASS = "org.sixstreams.search.engine.defaultClass";
    public static final String DEFAULT_ENGINE ="org.sixstreams.search.solr.SearchEngineImpl";
    private static Configuration config = null;

    public static final String META_TYPE_SEARCHABLE_OBJECT = "SearchableObject";
    public static final String USER_OBJECT_PERMISSION_CACHE_KEY_PREFIX = "UserObjectPermission";

    protected MetaDataManager() {

    }

    /**
     * Returns a SVO definition by loading it from view object xml. Does not
     * load extra data from database.
     *
     * @param qName name of the searchable object
     * @return Searchable object.
     */
    public static SearchableObject getSearchableObject(String qName) {
        return getSearchableObject(NO_ENGINE_INSTANCE_ID, qName);
    }

    /**
     * Factory method for searchable object. This method reads definition from
     * SVO definition.
     *
     * @param qName name of the searchable object
     * @param engineInstId id of the engine instance
     * @return Searchable object.
     */
    public static SearchableObject getSearchableObject(long engineInstId, String qName) {
        return getConfig().getSearchableObject(engineInstId, qName);
    }

    /**
     * Factory method for searchable group. This method reads definition from
     * SVO definition. If not found, null is returned. Call forceReload method
     * to synch up in memory cache.
     *
     * @param qName name of the searchable group
     * @param engineInstId id of the engine instance
     * @return Searchable group.
     */
    public static SearchableGroup getSearchableGroup(long engineInstId, String qName) {
        return getConfig().getSearchableGroup(engineInstId, qName);
    }

    /**
     * Returns all search groups.
     *
     * @return collection of searchable groups.
     */
    public static Collection<SearchableGroup> getSearchableObjectGroups(long engineInstId) {

        ArrayList<SearchableGroup> aList = new ArrayList<SearchableGroup>();
        aList.addAll(new ArrayList<SearchableGroup>(getConfig().getSearchableGroups(engineInstId)));
        Collections.sort(aList, new ComparatorSO());

        return aList;
    }

    /**
     * Get a list of search engine instances
     *
     * @return list
     */
    public static List<MetaEngineInstance> getEngineInstances() {
        ArrayList<MetaEngineInstance> engineInstances = new ArrayList<MetaEngineInstance>();
        engineInstances.addAll(new ArrayList<MetaEngineInstance>(getConfig().getEngineInstances()));
        return engineInstances;
    }

    public static List<MetaEngineInstance> getEngineInstances(long engineTypeId) {
        ArrayList<MetaEngineInstance> engineInstances = new ArrayList<MetaEngineInstance>();
        engineInstances.addAll(new ArrayList<MetaEngineInstance>(getConfig().getEngineInstances(engineTypeId)));
        return engineInstances;
    }

    /**
     * Gets a search engine instance
     *
     * @param engineId id of the engine instance
     * @return MetaEngineInstance
     */
    public static MetaEngineInstance getEngineInstance(long engineId) {
        List<MetaEngineInstance> engineInstances = getEngineInstances();
        for (int i = 0; i < engineInstances.size(); i++) {
            MetaEngineInstance engine = engineInstances.get(i);
            long eId = engine.getId();
            if (eId == engineId) {
                return engine;
            }
        }
        return null;
    }

    /**
     * Gets all Search Engine Instance parameters for a given instance from the
     * table.
     *
     * @param engineInstanceId
     * @return HashMap
     */
    public static Map<String, String> getEngineParameters(long engineInstanceId) {
        return getConfig().getEngineParameters(engineInstanceId);
    }

    public static synchronized Configuration getConfig() {
        // get system property
        String className = getProperty(CONFIG_CLASS, XmlConfiguration.class.getName());
		// if mConfig is not null, and mConfig is the same class as system
        // property
        // return the one created already

        if (config != null && config.getClass().getName().equals(className)) {
            return config;
        }
		// create a new configuration
        // use
        // -Dorg.sixstreams.configuration.class=org.sixstreams.meta.impl.BIConfiguration
        if (className != null) {
            config = (Configuration) ClassUtil.create(className);
        }

        if (config == null) {
            throw new RuntimeException("Failed to create configuration instance of type " + className);
        }

        return config;
    }

    public static void updateCacheItem(String type, Object obj) {
        getConfig().updateCacheItem(type, obj);
    }

    /**
     * Invalidates the cached item.
     *
     * @param type - the type of object (SearchableObject, etc).
     * @param obj - the object
     */
    public static void invalidateCacheItem(String type, Object obj) {
        getConfig().invalidateCacheItem(type, obj);
    }

    public static SearchEngine getSearchEngine(long engineId) {
        String connectorClass = null;
        if (engineId != -1) {
            MetaEngineInstance eng = MetaDataManager.getEngineInstance(engineId);
            if (eng != null) {
                connectorClass = eng.getEngineType();
            }
        } else {
            connectorClass = getProperty(ENGINE_DEFAULT_CLASS,DEFAULT_ENGINE);
        }
        return getSearchEngine(connectorClass);
    }

    private static SearchEngine getSearchEngine(String engineClass) {
        return (SearchEngine) ClassUtil.create(engineClass);
    }

    private static class ComparatorSO implements Comparator<SearchableGroup> {

        @Override
        public int compare(SearchableGroup arg0, SearchableGroup arg1) {
            // TODO Auto-generated method stub
            return arg0.getName().compareTo(arg1.getName());
        }

    }

    public static String getProperty(String propKey, String defaultValue) {
        String propertyValue = getProperty(propKey);
        if (propertyValue == null || propertyValue.length() == 0) {
            propertyValue = defaultValue;
        }
        return propertyValue;
    }

    public static String getProperty(String propKey) {
        String propValue = null;
        propValue = System.getProperty(propKey);
        if (propValue == null || propValue.length() == 0) {
            if (sPropertiesFileProps == null) {
                synchronized (sLock) {
                    if (sPropertiesFileProps == null) {
                        Properties properties = new Properties();
                        try {
                            InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream(PROPERTIES_FILE);
                            if (is == null) {
                                sLogger.severe("Failed to load property file " + PROPERTIES_FILE);
                            } else {
                                properties.load(is);
                                sLogger.info("Load property file " + PROPERTIES_FILE + " with " + properties.size() + " entries");
                            }
                        } catch (IOException ioe) {
                            sLogger.severe("Failed to load property file " + PROPERTIES_FILE + " - " + ioe.getMessage());
                        } finally {
                            sPropertiesFileProps = properties;
                        }
                    }
                }
            }
            propValue = sPropertiesFileProps.getProperty(propKey);
        }

        return propValue;
    }

    private static final String PROPERTIES_FILE = "sixstreams.properties";

    private static Object sLock = new Object();
    private static volatile Properties sPropertiesFileProps = null;
}
