package org.sixstreams.search.solr.index;

import java.io.IOException;

import java.io.Serializable;

import java.lang.reflect.Array;

import java.util.Collection;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.Constants;
import org.sixstreams.rest.IdObject;
import org.sixstreams.rest.writers.JSONWriter;
import org.sixstreams.search.Boostable;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchSecurityException;
import org.sixstreams.search.crawl.indexer.AbstractIndexer;

import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.solr.SearchEngineImpl;
import org.sixstreams.search.solr.SolrEngineImpl;
import org.sixstreams.search.solr.query.ObjectSearcherImpl;
import org.sixstreams.search.util.ContextFactory;

import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrException;
import org.apache.solr.common.SolrInputDocument;

public class IndexerImpl extends AbstractIndexer
{
	protected static Logger sLogger = Logger.getLogger(IndexerImpl.class.getName());

	private static final String UNKNOWN_FACT_VALUE = "unknown";

	public static final String SECURITY_ATTR_PREFIX = "SEC_";
	private SolrEngineImpl engine;
	private final int BATCH_SIZE = Integer.valueOf(MetaDataManager.getProperty("org.sixstreams.search.solr.index.batchSize"));
	private SearchableObject searchableObject = null;
	private long batchCount = 0L;
	private SolrServer solrServer;

	public IndexerImpl()
	{

	}

	public synchronized void deleteDocument(String url) throws SearchException
	{
		if (solrServer == null)
		{
			solrServer = engine.getSolrServer(searchableObject);
		}
		try
		{
			sLogger.fine("Deleting " + url);
			solrServer.deleteById(url);
			solrServer.commit();
		}
		catch (Exception e)
		{
			throw new SearchException("Failed to delete " + url, e);
		}
	}

	public void updateAttrValue(String attrName, String value)
	{
		ObjectSearcherImpl searcher = new ObjectSearcherImpl(this.engine);
		SolrDocument doc = searcher.getDocument(searchableObject, attrName, value);
		doc.setField(attrName, value);
	}

	public synchronized void indexBatch(List<IndexableDocument> docs)
	{
		if (solrServer == null)
		{
			solrServer = engine.getSolrServer(searchableObject);
		}

		try
		{
			batchCount = 0;
			for (IndexableDocument doc : docs)
			{
				if (batchCount > BATCH_SIZE)
				{
					batchCount = 0;
					solrServer.commit();
				}

				SolrInputDocument sb = createDocument(doc);
				if (doc instanceof Boostable)
				{
					sb.setDocumentBoost(((Boostable) doc).getBoost());
				}

				solrServer.add(sb);
				sLogger.fine("Document " + doc + " added to index.");
				batchCount++;
			}
			solrServer.commit();
		}
		catch (Exception sse)
		{
			sLogger.log(Level.SEVERE, "Failed to index document ", sse);	
		}
	}

	private synchronized void indexInternal(IndexableDocument doc)
	{
		if (solrServer == null)
		{
			solrServer = engine.getSolrServer(searchableObject);
		}

		try
		{
			SolrInputDocument sb = createDocument(doc);
			if (doc instanceof Boostable)
			{
				sb.setDocumentBoost(((Boostable) doc).getBoost());
			}
			solrServer.add(sb);
			sLogger.fine("Document " + doc + " added to index.");
			solrServer.commit();
		}
		catch (Exception sse)
		{
			sLogger.log(Level.SEVERE, "Failed to index document ", sse);
		}
	}

	public void deleteIndexByQuery(String query)
	{
		try
		{
			solrServer.deleteByQuery(query);
			solrServer.commit();
			sLogger.info("Detele by query executed - " + query);
		}
		catch (SolrServerException sse)
		{
			sLogger.log(Level.SEVERE, "Failed to delete index", sse);
		}
		catch (IOException ioe)
		{
			
			sLogger.log(Level.SEVERE, "Failed to delete index", ioe);
			
		}
	}

	private String binding2AttrName(AttributeDefinition ad, Object value)
	{
		return ad.getName() + SearchEngineImpl.getSuffix(ad, value);
	}

	private final static String WORD_DELIMITER = " \n";

	private String getCompositeContent(IndexableDocument indexableDocument)
	{

		String ctnt = indexableDocument.getContent();

		StringBuffer content = new StringBuffer(ctnt == null || ctnt.length() == 0 ? "" : ctnt + "\n");

		
		for (AttributeDefinition fieldDef : indexableDocument.getDocumentDef().getAttrDefs())
		{
			boolean index = !fieldDef.isSecure() && fieldDef.isIndexed();

			Object value = indexableDocument.getAttrValue(fieldDef.getName());
			if (index && value != null)
			{
				try
				{
					if (value.getClass().isArray())
					{
						for (int i = 0; i < Array.getLength(value); i++)
						{
							content.append(Array.get(value, i)).append(WORD_DELIMITER);
						}
					}
					else if (value instanceof Collection)
					{
						Collection<?> list = (Collection<?>) value;
						for (Object object : list)
						{
							content.append(object).append(WORD_DELIMITER);
						}
					}
					else
					{
						content.append(value).append(WORD_DELIMITER);	
					}
				}
				catch (Throwable e)
				{
					content.append(value).append(WORD_DELIMITER);
				}
			}
		}
		sLogger.fine(content + " indexed");
		return content.toString();
	}

	/**
	 * Make a Document object with an un-indexed title field and an indexed
	 * content field.
	 */
	private SolrInputDocument createDocument(IndexableDocument indexableDocument) throws SearchSecurityException
	{
		SearchableObject so = indexableDocument.getSearchableObject();
		SolrInputDocument solrDocument = null;
		if (so != null)
		{
			solrDocument = createDocumentWtihSo(indexableDocument);
		}
		else
		{
			solrDocument = createDocumentWtihoutSO(indexableDocument);
		}
		return solrDocument;
	}

	private SolrInputDocument createDocumentWtihoutSO(IndexableDocument indexableDocument) throws SearchSecurityException
	{

		SolrInputDocument doc = new SolrInputDocument();

		doc.addField(Constants.PRIMARY_KEY, "" + indexableDocument.getPrimaryKey());
		String title = indexableDocument.getTitle();

		String content = getCompositeContent(indexableDocument);
		// allows content to be read from a cache file
		if (content != null && content.startsWith("cache:"))
		{
			// open the file, read it and remove it
		}

		doc.addField(Constants.TITLE, title);
		doc.addField(Constants.CONTENT, content);

		doc.addField(Constants.SO_NAME, "NO_SO");

		// Map fields = indexableDocument.getFields();
		DocumentDefinition df = indexableDocument.getDocumentDef();
		Collection<AttributeDefinition> collection = df.getAttrDefs();
		for (AttributeDefinition fd : collection)
		{
			String key = fd.getName();
			Object value = indexableDocument.getAttrValue(key);

			if (fd.isStored() && value != null)
			{
				if (value instanceof List)
				{
					List<?> values = (List<?>) value;
					if (values.size() > 0 && values.get(0) instanceof Serializable)
					{
						if (values.get(0) instanceof String && fd.isFacetAttr())
						{
							for(int i = 0; i<values.size(); i++)
							{
								value = values.get(i);
								doc.addField(binding2AttrName(fd, value), value);
							}
						}
						else
						{
							JSONWriter jsonWriter = new JSONWriter();
							value = jsonWriter.toString(value);
							doc.addField(binding2AttrName(fd, value), value);
						}
					}
				}
				else if (value instanceof Serializable)
				{
					JSONWriter jsonWriter = new JSONWriter();
					value = jsonWriter.toString(value);
					doc.addField(binding2AttrName(fd, value), value);
				}
			}

			if (fd.isSecure())
			{
				List<String> attrAcl = indexableDocument.getAttributeAcl(key);
				if (attrAcl != null && attrAcl.size() > 0)
				{
					StringBuffer stringValue = new StringBuffer();
					boolean moreThanOne = false;
					for (String ace : attrAcl)
					{
						if (moreThanOne)
						{
							stringValue.append(" ");
						}
						stringValue.append(ace);
						moreThanOne = true;
					}
					if (Constants.ACL_KEY.equals(fd.getName()))
					{
						doc.addField(Constants.ACL_KEY, stringValue);
					}
					else
					{
						doc.addField(SECURITY_ATTR_PREFIX + fd.getName(), stringValue);
					}
				}
			}
		}
		return doc;
	}

	private SolrInputDocument createDocumentWtihSo(IndexableDocument indexableDocument) throws SearchSecurityException
	{
		SolrInputDocument doc = new SolrInputDocument();

		SearchableObject so = indexableDocument.getSearchableObject();
		if (indexableDocument.getPrimaryKey() != null)
		{
			doc.addField(Constants.PRIMARY_KEY, "" + indexableDocument.getPrimaryKey());
		}

		String title = indexableDocument.getTitle();
		String content = getCompositeContent(indexableDocument);
		// allows content to be read from a cache file
		if (content != null && content.startsWith("cache:"))
		{
			// open the file, read it and remove it
		}

		doc.addField(Constants.TITLE, title);
		doc.addField(Constants.CONTENT, content);
		doc.addField(Constants.SO_NAME, so.getName());

		List<String> acls = indexableDocument.getAcl();
		if (acls != null && acls.size() > 0)
		{
			StringBuffer stringValue = new StringBuffer();
			boolean moreThanOne = false;
			for (String ace : acls)
			{
				if (moreThanOne)
				{
					stringValue.append(" ");
				}
				stringValue.append(ace);
				moreThanOne = true;
			}
			doc.addField(Constants.ACL_KEY, stringValue);
		}

		for (String key : indexableDocument.getAttributeNames())
		{
			AttributeDefinition fd = so.getDocumentDef().getAttributeDef(key);
			if (fd != null)
			{
				if (fd.isStored())
				{
					Object value = indexableDocument.getAttrValue(fd.getName());

					if (fd.isFacetAttr() && value == null)
					{
						value = UNKNOWN_FACT_VALUE;
					}

					if (value != null)
					{
						// serialize data object, children
						if (value instanceof List)
						{
							List<?> values = (List<?>) value;
							if (values.size() > 0 && (values.get(0) instanceof Serializable || values.get(0) instanceof IdObject))
							{
								JSONWriter jsonWriter = new JSONWriter();
								value = jsonWriter.toJson(values);
							}
						}
						else if (value instanceof IdObject)
						{
							JSONWriter jsonWriter = new JSONWriter();
							value = jsonWriter.toJson(value);
						}

						String attrName = binding2AttrName(fd, value);
						if (value instanceof StringBuffer)
						{
							value = value.toString();
						}
						
						if (fd.isEncrypted())
						{
							SearchContext ctx = ContextFactory.getSearchContext();
							try
							{
								value = ctx.getCryptor().encrypt(value);
							}
							catch (Exception e)
							{
								//will not stored
								sLogger.severe("Failed to encrypt secret value");
								value = "";
							}
						}
						doc.addField(attrName, value);
					}
				}

				if (fd.isSecure())
				{
					
					List<String> acl = indexableDocument.getAttributeAcl(fd.getName());
					
					if (acl != null && acl.size() > 0)
					{
						StringBuffer stringValue = new StringBuffer();
						boolean moreThanOne = false;
						for (String ace : acl)
						{
							if (moreThanOne)
							{
								stringValue.append(" ");
							}
							stringValue.append(ace);
							moreThanOne = true;
						}
						doc.addField(SECURITY_ATTR_PREFIX + fd.getName(), stringValue);
					}
				}
			}
		}
		return doc;
	}

	public IndexerImpl(SearchableObject obj, SolrEngineImpl engine)
	{
		searchableObject = obj;
		this.engine = engine;
		solrServer = engine.getSolrServer(searchableObject);
	}

	// implementation of Indexer

	public void setSearchableObject(SearchableObject searchableObject)
	{
		this.searchableObject = searchableObject;
	}

	public synchronized void close()
	{
		try
		{
			if (solrServer != null)
			{
				try
				{
					solrServer.commit();
				}
				catch (SolrException sse)
				{
					sse.printStackTrace();
				}
				solrServer = null;
			}
		}
		catch (Exception sse)
		{
			sLogger.log(Level.SEVERE, "Failed to close the server", sse);
		}
	}

	boolean buzy = false;

	public AbstractIndexer clone()
	{
		return (org.sixstreams.search.crawl.indexer.AbstractIndexer) engine.getIndexer();
	}

	public synchronized void indexDocument(IndexableDocument doc)
	{
		buzy = true;
		indexInternal(doc);
		buzy = false;
	}

	public boolean isBusy()
	{
		return buzy;
	}
}
