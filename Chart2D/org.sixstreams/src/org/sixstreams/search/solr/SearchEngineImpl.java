package org.sixstreams.search.solr;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.embedded.EmbeddedSolrServer;
import org.apache.solr.core.CoreContainer;
import org.apache.solr.core.CoreDescriptor;
import org.apache.solr.core.SolrCore;
import org.apache.solr.core.SolrResourceLoader;
import org.sixstreams.Constants;
import org.sixstreams.search.Administrator;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.Crawler;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.Indexer;
import org.sixstreams.search.LifeCycleListener;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.Searcher;
import org.sixstreams.search.crawl.crawler.CrawlableFactory;
import org.sixstreams.search.crawl.crawler.IndexableDocumentImpl;
import org.sixstreams.search.facet.FacetDef;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.solr.index.IndexerImpl;
import org.sixstreams.search.solr.query.ObjectSearcher;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;
import org.xml.sax.InputSource;

public class SearchEngineImpl extends SolrEngineImpl
{
	public static final String INDEX_DIRECTORY_KEY = "org.sixstreams.search.solr.objectName";
	public static final String INDEX_LOCATION_KEY = "org.sixstreams.search.solr.index.location";

	protected static Logger sLogger = Logger.getLogger(SearchEngineImpl.class.getName());
	
	static Map<String, EmbeddedSolrServer> sServers = new Hashtable<String, EmbeddedSolrServer>();

	private static String ABOUT = "This implementation uses lucene with solr as its search engine.";
	private String name;

	private static CoreContainer coreContainer = null;
	private String location = null;
	private List<LifeCycleListener> mLifeCycleListners = new ArrayList<LifeCycleListener>();

	public SearchEngineImpl()
	{

	}

	public static String getAttrName(String fd)
	{
		if (fd.endsWith("_ms"))
		{
			return fd.substring(0, fd.length() - 3);
		}
		else if (fd.endsWith("_d"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_dt"))
		{
			return fd.substring(0, fd.length() - 3);
		}
		else if (fd.endsWith("_s"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_i"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_l"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_b"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_f"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else if (fd.endsWith("_t"))
		{
			return fd.substring(0, fd.length() - 2);
		}
		else
		{
			return fd;
		}
	}

	public static String getSuffix(FacetDef def, SearchableObject so)
	{
		AttributeDefinition ad = so.getDocumentDef().getAttrDefByName(def.getAttrName());
		return getSuffix(ad, so);
	}

	public static String getSuffix(AttributeFilter af)
	{
		Object value = af.getAttrValue();
		if (value == null)
		{
			value = af.getHiValue();
		}
		if (value == null)
		{
			value = af.getLoValue();
		}
		return getSuffix(af.getAttrbuteType(), value);
	}

	public static String getSuffix(AttributeDefinition ad)
	{
		if (ad == null)
		{
			return "";
		}
		else
		{
			return getSuffix(ad.getDataType(), null);
		}
	}

	public static String getSuffix(AttributeDefinition ad, Object value)
	{
		if (ad == null)
		{
			return _getSuffix(value);
		}
		else
		{
			return getSuffix(ad.getDataType(), value);
		}
	}

	private static String getSuffix(String dataType, Object value)
	{
		if (dataType == null || dataType.length() == 0)
		{
			return _getSuffix(value);
		}

		if (dataType.equals(Constants.STRING_ARRAY))
		{
			return "_ms";
		}
		else if (dataType.equals(List.class.getName()) && value instanceof List)
		{
			return "_ms";
		}
		else if (dataType.equals(String.class.getName()))
		{
			return "_s";
		}
		else if (dataType.equals(Date.class.getName()))
		{
			return "_dt";
		}
		else if (dataType.equals(Double.class.getName()) || "double".equals(dataType))
		{
			return "_d";
		}
		else if (dataType.equals(Long.class.getName()) || "long".equals(dataType))
		{
			return "_l";
		}
		else if (dataType.equals(Integer.class.getName()) || "int".equals(dataType))
		{
			return "_i";
		}
		else if (dataType.equals(Boolean.class.getName()) || "boolean".equals(dataType))
		{
			return "_b";
		}
		else if (dataType.equals(Float.class.getName()) || "float".equals(dataType))
		{
			return "_f";
		}
		else if (dataType.equals(StringBuffer.class.getName()))
		{
			return "_s";
		}
		else
		{
			return _getSuffix(value);
		}
	}


	public SolrServer getSolrServer(SearchableObject object)
	{
		if (object == null)
		{
			return getSolrServer();
		}
		else
		{
			return getSolrServer(object.getName());
		}
	}
	
	public List<LifeCycleListener> getLifeCycleListners()
	{
		return mLifeCycleListners;
	}
	
//private methods
	private static String _getSuffix(Object value)
	{
		if (value instanceof Object[])
		{
			Class<?> cls = value.getClass().getComponentType();
			if (cls.equals(String.class))
			{
				return "_ms";
			}
		}
		else if (value instanceof List)
		{
			return "_ms";
		}
		else if (value instanceof StringBuffer)
		{
			return "_s";
		}
		else if (value instanceof Date)
		{
			return "_dt";
		}
		else if (value instanceof Long)
		{
			return "_l";
		}
		else if (value instanceof Float)
		{
			return "_f";
		}
		else if (value instanceof Integer)
		{
			return "_i";
		}
		else if (value instanceof Boolean)
		{
			return "_b";
		}
		else if (value instanceof Double)
		{
			return "_d";
		}
		else if (value instanceof String)
		{
			return "_s";
		}
		return "_obj"; // serialize objects
	}

	private String getLocation(String objectName)
	{
		String dir = getLocation();
		if (objectName != null)
		{
			dir = dir + File.separator + objectName.replaceAll("\\.", "_");
		}
		return dir;
	}
	
	

	private synchronized CoreContainer getContainer()
	{
		if (coreContainer == null)
		{
			try
			{
				InputSource source = new InputSource(Thread.currentThread().getContextClassLoader().getResourceAsStream("solr.xml"));
				coreContainer = new CoreContainer(new SolrResourceLoader(getLocation(), Thread.currentThread().getContextClassLoader())) ;
				coreContainer.load(getLocation(), source);
			}
			catch (Exception saxe)
			{
				saxe.printStackTrace();
				throw new RuntimeException("Failed to initialize solr search engine", saxe);
			}
		}
		return coreContainer;
	}

	private String getCoreName(String objectName)
	{
		String location = getLocation(objectName);
		String separator = File.separator;

		if ("\\".equals(separator))
		{
			separator = "\\\\";
		}

		String name = location.replaceAll(separator, "_");
		if (name.contains(":"))
		{
			name = name.replaceAll(":", "_");
		}

		return name;
	}

	private void setupCore(String objectName)
	{
		CoreContainer container = getContainer();
		String location = getLocation(objectName);
		String name = getCoreName(objectName);
		if (container.getCore(name) == null)
		{
			try
			{
				CoreDescriptor descriptor = new CoreDescriptor(container, name, getLocation());
				descriptor.setDataDir(location);
				SolrCore solrCore = container.create(descriptor);
				solrCore = container.register(solrCore, false);
			}
			catch (Exception saxe)
			{
				saxe.printStackTrace();
			}
		}
	}

	private EmbeddedSolrServer getSolrServer()
	{
		SearchContext ctx = ContextFactory.getSearchContext();
		String objectName = (String) ctx.getAttribute(INDEX_DIRECTORY_KEY);
		return getSolrServer(objectName);
	}

	private EmbeddedSolrServer getSolrServer(String objectName)
	{
		EmbeddedSolrServer server = sServers.get(objectName);
		if (server != null)
		{
			return server;
		}

		setupCore(objectName);
		server = new EmbeddedSolrServer(getContainer(), getCoreName(objectName));
		sServers.put(objectName, server);

		return server;
	}

	public Administrator getAdministrator()
	{
		return (Administrator) ClassUtil.create("org.sixstreams.admin.AdministratorImpl");
	}

	public String getName()
	{
		return name;
	}

	public String getDescription()
	{
		return ABOUT;
	}

	public Searcher getSearcher()
	{
		return new ObjectSearcher(this);
	}

	public Crawler getCrawler()
	{
		return CrawlableFactory.getCralwer(ContextFactory.getSearchContext().getSearchableObject());
	}

	public Indexer getIndexer()
	{
		return new IndexerImpl(ContextFactory.getSearchContext().getSearchableObject(), this);
	}

	public IndexableDocument createIndexableDocument(SearchableObject searchableObject)
	{
		return new IndexableDocumentImpl(searchableObject);
	}

	public synchronized void cleanup()
	{
		if (sServers != null && sServers.size() > 0)
		{
			for (EmbeddedSolrServer server : sServers.values())
			{
				try
				{
					server.commit();
				}
				catch (Exception e)
				{
					e.printStackTrace();
				}
			}
			sServers = new Hashtable<String, EmbeddedSolrServer>();
		}
		
		if (coreContainer != null)
		{
			coreContainer.shutdown();
			coreContainer = null;
		}
	}

	// programmatically override the location

	public void setLocation(String location)
	{
		this.location = location;
	}

	private static final String INDEX_LOCATION = File.separator + "sixstreams" + File.separator + "solr" + File.separator + "data";
	private static final String JAVA_TEMP_DIR_KEY = "java.io.tmpdir";

	public String getLocation()
	{
		if (location == null)
		{
			location = MetaDataManager.getProperty(INDEX_LOCATION_KEY, System.getProperty(JAVA_TEMP_DIR_KEY) + INDEX_LOCATION);
			sLogger.info("Your solr index should be located here " + location);
		}
		return location;
	}
}
