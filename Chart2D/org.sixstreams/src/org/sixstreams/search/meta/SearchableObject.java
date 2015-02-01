package org.sixstreams.search.meta;

import java.io.IOException;
import java.io.Serializable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchSecurityException;
import org.sixstreams.search.facet.FacetDef;
import org.sixstreams.search.impl.DefaultSearchPlugin;
import org.sixstreams.search.meta.action.SearchResultActionDef;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;

/**
 * The <code>SearchableObject</code> represents search related meta data for a
 * business object.
 * 
 */
public class SearchableObject implements Serializable
{
	private String plugInName = DefaultSearchPlugin.class.getName();

	// Schema name that database table belongs to
	private String schemaName; // mandatory

	// date this object was crawled
	private Date lastTimeCrawled;

	private long searchEngineInstanceId = -1;

	private List<FacetDef> searchFacetDefs = new ArrayList<FacetDef>();

	// reference of search engine. This value might be required when make
	// a query to the search engine
	private String searchEngineReference;

	// Plug-in service
	private transient Object plugIn;

	// id field of this object, related to fnd_objects.object_id
	private String id;

	// Root document
	private DocumentDefinition documentDef;

	private String title;
	private String content;
	private String keywords;

	private SearchPluginDef searchPlugIn = null;
	private SearchResultActionDef[] searchActions = null;

	private boolean deployed = false;
	private boolean active = true;
	private boolean secure = false;
	private String applId;
	private long componentId;

	private long indexSceduleId;

	private String name;
	private Hashtable<String, String> properties = new Hashtable<String, String>();

	public SearchableObject()
	{
		super();
	}

	/**
	 * Constructs searchable from a name
	 * 
	 * @param name
	 */
	public SearchableObject(String name)
	{
		this.name = name;
	}

	/**
	 * Gets Schema name.
	 */
	public String getSchemaName()
	{
		return schemaName;
	}

	// to be overriden to initialize this object
	// this is the good place to create document definition model

	public void initializeConfig()
	{
		// we do nothing here
	}

	/**
	 * Gets display name.
	 * 
	 * @return displayName.
	 */
	public String getDisplayName()
	{
		return getName();
	}

	/**
	 * Sets root mDocumentDef for this object.
	 * 
	 * @param doc
	 *            definition.
	 */
	public void setDocumentDef(AbstractDocumentDefinition doc)
	{
		this.documentDef = doc;
		this.documentDef.setSearchableObject(this);
	}

	/**
	 * Returns root mDocumentDef.
	 * 
	 * @return Document definition.
	 */
	public DocumentDefinition getDocumentDef()
	{
		return documentDef;
	}

	public void setSearchEngineInstanceId(long seiId)
	{
		searchEngineInstanceId = seiId;
	}

	public long getSearchEngineInstanceId()
	{
		return searchEngineInstanceId;
	}

	/**
	 * Gets a service bean.
	 * 
	 * @throw SearchSecurityException if fails to instantiate a search service.
	 * 
	 **/
	public Object getSearchPlugin() throws SearchSecurityException
	{
		if (plugIn != null)
		{
			return plugIn;
		}
		plugIn = ClassUtil.create(plugInName);
		return plugIn;
	}

	/**
	 * Sets last time when this object crawled but dont have to propagate to DB
	 * (because it is already there).
	 */

	public void setLastTimeCrawled(Date lastTimeCrawled)
	{
		this.lastTimeCrawled = lastTimeCrawled;
	}

	/**
	 * Sets last time when this object crawled. This should be persisted in to
	 * transactional database.
	 */
	public void resetLastTimeCrawled(Date lastTimeCrawled) throws SearchException
	{

		this.lastTimeCrawled = lastTimeCrawled;

		// update the cache
		MetaDataManager.updateCacheItem(MetaDataManager.META_TYPE_SEARCHABLE_OBJECT, this);

		if (getId() == null)
		{
			return;
		}

	}

	/**
	 * Returns time last this searchable object is crawled.
	 */
	public Date getLastTimeCrawled()
	{
		return lastTimeCrawled;
	}

	/**
	 * Sets the reference value for this definition in a search engine.
	 * 
	 * @param searchEngineReference
	 */
	public void setSearchEngineReference(String searchEngineReference)
	{
		this.searchEngineReference = searchEngineReference;
	}

	/**
	 * Returns search engine reference for this searchable object.
	 * 
	 * @return search engine reference.
	 */
	public String getSearchEngineReference()
	{
		return searchEngineReference == null ? "" : searchEngineReference;
	}

	/**
	 * Sets plugin name. This must be a valid Java class name.
	 * 
	 * @param plugInName
	 *            class name of the plugin for this searchable object.
	 */
	public void setPlugInName(String plugInName)
	{
		this.plugInName = plugInName;
	}

	/**
	 * Returns plugin name for this object.
	 * 
	 * @return name of plugin name.
	 */
	public String getPlugInName()
	{
		return plugInName;
	}

	/**
	 * Creates an indexable mDocumentDef instance. This method delegates the
	 * creation logic to the search engine.
	 * 
	 */
	public IndexableDocument createIndexableDocument()
	{
		SearchEngine searchEngine = MetaDataManager.getSearchEngine(this.searchEngineInstanceId);
		return searchEngine.createIndexableDocument(this);
	}

	/**
	 * Sets id of this object. This is used internally when it is synched with
	 * database.
	 * 
	 * @param id
	 *            the new id for this object.
	 */
	public void setId(String id)
	{
		this.id = id;
	}

	/**
	 * Returns mId of this object. If null, meaning the object has not been
	 * loaded into database.
	 * 
	 * @return id of this object.
	 */
	public String getId()
	{
		return id;
	}

	/**
	 * Sets indexScehduleId of this object. This method is not for external
	 * consumption
	 * 
	 * @param id
	 *            the index schedule id for this object.
	 */
	public void setScheduleId(long id)
	{
		indexSceduleId = id;
	}

	/**
	 * This method is not for external consumption
	 * 
	 * @return id of the index scehdule this object associated to.
	 */
	public long getScheduleId()
	{
		return indexSceduleId;
	}

	public void setActive(boolean isActive)
	{
		this.active = isActive;
	}

	public boolean isActive()
	{
		return active;
	}

	public void setDeployed(boolean isDeployed)
	{
		this.deployed = isDeployed;
	}

	public boolean isDeployed()
	{
		return deployed;
	}

	/**
	 * Sets title definition in groovy expression.
	 * 
	 * @param title
	 *            the groovy exression used as title for documents genertated
	 *            for this searchable object.
	 */
	public void setTitle(String title)
	{
		this.title = title;
	}

	/**
	 * Returns title definition for this object. It is a groovy expression.
	 * 
	 * @return the title definition.
	 */
	public String getTitle()
	{
		return title;
	}

	/**
	 * Sets body definition. it should be a groovy expression.
	 * 
	 * @param content
	 *            the groovy expresion used as body for the searchable object.
	 */
	public void setContent(String content)
	{
		this.content = content;

	}

	/**
	 * Gets body definition per developers of the searchable object. This should
	 * be a groovy expression.
	 * 
	 * @return the body definition.
	 */
	public String getContent()
	{
		return content;
	}

	/**
	 * Sets keywords defintion. This should be an groovy expression
	 * 
	 * @param keywords
	 *            the groovy expression used as keywords
	 */
	public void setKeywords(String keywords)
	{
		this.keywords = keywords;

	}

	/**
	 * Returns keywords definition for this searchable object. It should be a
	 * groovy expression.
	 * 
	 * @return keywords defnition in groovy expression.
	 */
	public String getKeywords()
	{
		return keywords;
	}

	/**
	 * Sets security plugin definition. This is for internal use only.
	 * 
	 * @param plugIn
	 *            @SearchPluginDef is an internal class wraps plugin definition
	 *            for a searchable object.
	 */
	public void setSearchPlugIn(SearchPluginDef plugIn)
	{
		this.searchPlugIn = plugIn;
	}

	/**
	 * Returns plugin definition for this object.
	 * 
	 * @return SearchPluginDef that contains definition of the plugin.
	 */
	public SearchPluginDef getSearchPlugIn()
	{
		return searchPlugIn;
	}

	/**
	 * Sets action definitions to this object. Action definitions can be stored
	 * by a @Configuration. This is the method to access it.
	 * 
	 * @param actions
	 *            an array of action defnitions.
	 */
	public void setSearchActions(SearchResultActionDef[] actions)
	{
		this.searchActions = actions;
	}

	/**
	 * Returns an array of search actions assigned to this object.
	 * 
	 * @return an array of search action definitions.
	 */
	public SearchResultActionDef[] getSearchActions()
	{
		return searchActions;
	}

	/**
	 * Returns default action definition object.
	 * 
	 * @return default action definiiton.
	 */
	public SearchResultActionDef getDefaultActionDef()
	{
		if (searchActions != null)
		{
			for (int i = 0; i < searchActions.length; i++)
			{
				SearchResultActionDef action = searchActions[i];

				if (action.isDefaultAction())
				{
					// parse the groovy expression
					return action;
				}
			}
			return null;
		}
		return null;
	}

	/**
	 * Returns the default aciton title in groovy expression.
	 * 
	 * @return the groovy expression assigned as default action title.
	 */
	public String getDefaultActionTitle()
	{
		SearchResultActionDef action = getDefaultActionDef();

		if (action != null)
		{
			return action.getTitle();
		}
		return null;
	}

	/**
	 * A convenient method to get Facet Defitions associated to this searchable
	 * object.
	 * 
	 * @return an array of facet definitions.
	 */

	public List<FacetDef> getFacetDefs()
	{
		return searchFacetDefs;
	}

	/**
	 * Returns the name of Crawlable Factory used for this object.
	 */
	public String getCrawlableFactoryName()
	{
		return null;
	}

	/**
	 * set the application id
	 * 
	 * @param applId
	 *            an application id string
	 */
	public void setApplId(String applId)
	{
		this.applId = applId;
	}

	/**
	 * get the application id
	 * 
	 * @return an application id string
	 */
	public String getApplId()
	{
		return applId;
	}

	/**
	 * Set the remote server id for global search
	 * 
	 * @param componentId
	 *            the new component Id for this object.
	 */

	public void setComponentId(long componentId)
	{
		this.componentId = componentId;
	}

	/**
	 * Get the remote server id for global search
	 * 
	 * @return component id this objectd belongs to.
	 */

	public long getComponentId()
	{
		return componentId;
	}

	/**
	 * Get the property.
	 * 
	 * @param key
	 *            Property key
	 * @return Property value
	 */
	public String getProperty(String key)
	{
		if (key != null)
		{
			return properties.get(key);
		}
		return null;
	}

	/**
	 * Set the property.
	 * 
	 * @param key
	 *            Property key
	 * @param value
	 *            Property value
	 */
	public void setProperty(String key, String value)
	{
		if (key != null)
		{
			if (value != null)
			{
				properties.put(key, value);
			}
			else
			{
				properties.remove(key);
			}
		}
	}

	public Collection<FacetDef> getSearchFacetDefs()
	{
		return searchFacetDefs;
	}

	public void addSearchFacetDef(FacetDef sfd)
	{
		searchFacetDefs.add(sfd);
	}

	/**
	 * Get the properties.
	 * 
	 * @return Properties
	 */
	public Hashtable<String, String> getProperties()
	{
		return properties;
	}

	/**
	 * Recursively set the searchable object on document definitions. Used
	 * during deserialization.
	 * 
	 * @param doc
	 * @param so
	 */
	private void setDocumentSearchableObject(DocumentDefinition doc, SearchableObject so)
	{
		doc.setSearchableObject(so);

		// recursively set so on child document definitions.
		for (Object childDoc : doc.getChildDocumentDefs())
		{
			setDocumentSearchableObject((AbstractDocumentDefinition) childDoc, so);
		}
	}

	/**
	 * Custom serialization routine.
	 * 
	 * @param out
	 * @throws IOException
	 */
	private void writeObject(java.io.ObjectOutputStream out) throws IOException
	{
		out.defaultWriteObject();
	}

	/**
	 * Custom deserialization routine.
	 * 
	 * @param in
	 * @throws IOException
	 * @throws ClassNotFoundException
	 */
	private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException
	{
		in.defaultReadObject();

		// set the transient searchableObject member variable on child
		// documents.
		if (documentDef != null)
		{
			setDocumentSearchableObject(documentDef, this);
		}
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getName()
	{
		return name;
	}

	public boolean isSecure()
	{
		return secure;
	}

	public void setSecure(boolean secure)
	{
		this.secure = secure;
	}
}
