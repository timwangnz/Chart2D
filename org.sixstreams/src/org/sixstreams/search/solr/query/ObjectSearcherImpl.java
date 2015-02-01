package org.sixstreams.search.solr.query;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.TimeZone;
import java.util.logging.Logger;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.client.solrj.response.UpdateResponse;
import org.apache.solr.common.SolrDocument;
import org.sixstreams.Constants;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchSecurityException;
import org.sixstreams.search.Securable;
import org.sixstreams.search.facet.FacetManager;
import org.sixstreams.search.facet.FacetPath;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableGroup;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.HitsMetaDataImpl;
import org.sixstreams.search.query.IndexedDocumentImpl;
import org.sixstreams.search.query.QueryMetaDataImpl;
import org.sixstreams.search.query.SearchGroup;
import org.sixstreams.search.solr.SearchEngineImpl;
import org.sixstreams.search.solr.SolrEngineImpl;
import org.sixstreams.search.solr.index.IndexerImpl;

public class ObjectSearcherImpl 
{
	private static Logger sLogger = Logger.getLogger(ObjectSearcherImpl.class.getName());
	private final static SimpleDateFormat ISO8601FORMAT = new SimpleDateFormat("yyyy-MM-dd'T'HH\\:mm\\:ss'Z'");
	//private final static String OR_OP = "{!lucene q.op=OR}";

	private SolrEngineImpl engine;
	private long engineId;
	private QueryMetaData qmd;
	private SearchableObject searchableObject;

	public ObjectSearcherImpl(SolrEngineImpl engineImpl)
	{
		engine = engineImpl;
	}

	public ObjectSearcherImpl(SolrEngineImpl engineImpl, Long engineId, QueryMetaData qmd, SearchableObject searchableObject) throws SearchException
	{

		this.engineId = engineId;
		this.qmd = qmd;
		engine = engineImpl;
		if (searchableObject != null)
		{
			this.searchableObject = searchableObject;
		}
	}

	protected void init() throws SearchException
	{
		List<SearchGroup> groups = qmd.getSearchGroups();
		if (groups == null || groups.size() == 0)
		{
			throw new SearchException("Search group can not be null or empty for query API.");
		}

		List<SearchableGroup> sgs = new ArrayList<SearchableGroup>();
		for (SearchGroup g : groups)
		{
			SearchableGroup sg = MetaDataManager.getSearchableGroup(g.getSearchEngineInstanceId(), g.getName());
			if (sg != null)
			{
				sgs.add(MetaDataManager.getSearchableGroup(g.getSearchEngineInstanceId(), g.getName()));
			}
		}
	}

	public long getEngineId()
	{
		return engineId;
	}

	public SearchableObject getSearchableObject()
	{
		return searchableObject;
	}

	public IndexedDocument createIndexedDocument(SearchContext ctx, List<AttributeValue> attributes)
	{
		return new IndexedDocumentImpl(ctx, attributes);
	}

	private String checkQuery(String query)
	{
		if (query == null || query.length() == 0)
		{
			return Constants.WILDCARD_CHAR;
		}
		return query;
	}

	private void addFilter(SolrQuery solrQuery, AttributeFilter filter)
	{
		if (filter.getAttrValue() instanceof Date)
		{
			ISO8601FORMAT.setTimeZone(TimeZone.getTimeZone("UTC"));
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":" + ISO8601FORMAT.format((Date) filter.getAttrValue())
			});
		}
		else if (Constants.OPERATOR_CONTAINS.equals(filter.getOperator()))
		{
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":*" + filter.getAttrValue() + "*"
			});
		}
		else if (Constants.OPERATOR_GT.equals(filter.getOperator()))
		{
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":[" + filter.getAttrValue() + " TO *]"
			});
		}
		else if (Constants.OPERATOR_RANGE.equals(filter.getOperator()))
		{
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":[" + filter.getLoValue() + " TO " + filter.getHiValue() + "]"
			});
		}
		else if (Constants.OPERATOR_LT.equals(filter.getOperator()))
		{
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":[* TO " + filter.getAttrValue() + "]"
			});
		}
		else
		{
			solrQuery.addFilterQuery(new String[]
			{
				filter.getAttrName() + ":" + filter.getAttrValue()
			});
		}
	}

	private SolrQuery getQuery(QueryMetaData qmd) throws SearchSecurityException
	{
		SolrQuery solrQuery = new SolrQuery();
		
		String query = checkQuery(qmd.getQueryString());

		solrQuery.setIncludeScore(true);
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		filters.addAll(convertFilters(qmd.getAssignedFilters()));

		if (qmd instanceof QueryMetaDataImpl)
		{
			filters.addAll(convertFilters(((QueryMetaDataImpl) qmd).getInternalFilters()));
		}
		filters.addAll(getFacetAttrFilters(qmd));

		long start = qmd.getOffset();

		solrQuery.setStart(Integer.valueOf("" + start));

		solrQuery.setRows(qmd.getPageSize());

		if (!Constants.WILDCARD_CHAR.equals(query))
		{
			solrQuery.addHighlightField(Constants.TITLE);
			solrQuery.addHighlightField(Constants.CONTENT);
			solrQuery.setHighlightFragsize(80);
			solrQuery.setHighlightSnippets(3);
			solrQuery.setHighlightRequireFieldMatch(false);
			solrQuery.setHighlightSimplePre("<b>").setHighlightSimplePost("</b>");
		}

		solrQuery.setQuery(query);
		
		for (int i = 0; i < filters.size(); i++)
		{
			AttributeFilter filter = filters.get(i);
			addFilter(solrQuery, filter);
		}

		if (qmd.isFacetsEnabled())
		{
			List<String> facetAttrs = qmd.getFacetNames();
			
			if (!facetAttrs.isEmpty())
			{
				facetAttrs = convertAttrNames(facetAttrs);
				solrQuery.setFacet(true);
				solrQuery.setFacetMinCount(1);
				solrQuery.setFacetLimit(qmd.getMaxFacetValues());
				solrQuery.addFacetField(facetAttrs.toArray(new String[]{}));
			}
		}

		String disableQuerySecurity = MetaDataManager.getProperty(Constants.SECURITY_DISABLED);
		if (!"TRUE".equals(disableQuerySecurity))
		{
			installSecurityFilters(solrQuery);
		}
		else
		{
			sLogger.fine("Query security is disabled, check your sixstreams/system property org.sixstreams.query.security.disabled");
		}

		if (qmd.getOrderBy() != null)
		{
			AttributeDefinition ad = searchableObject.getDocumentDef().getAttrDefByName(qmd.getOrderBy());
			if (ad == null)
			{
				sLogger.warning("Order by attribute not found for object " + searchableObject + " " + qmd.getOrderBy());
			}
			else
			{
				String suffix = SearchEngineImpl.getSuffix(ad);
				solrQuery.addSortField(qmd.getOrderBy() + suffix, QueryMetaData.DESC.equals(qmd.getOrderByDir()) ? SolrQuery.ORDER.desc : SolrQuery.ORDER.asc);
			}
		}
		return solrQuery;
	}
	private List<String> convertAttrNames(List<String> attrNames)
	{
		ArrayList<String> solrAttrNames = new ArrayList<String>();
		for (String attrName : attrNames)
		{
			solrAttrNames.add(attrName + "_s");
		}
		return solrAttrNames;
	}
	private List<AttributeFilter> convertFilters(List<AttributeFilter> qmdFilters)
	{
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		if (qmdFilters == null)
		{
			return filters;
		}

		for (AttributeFilter ff : qmdFilters)
		{
			if (ff.getAttrName().equals(Constants.SO_NAME))
			{
				filters.add(ff);
				continue;
			}

			AttributeFilter attrFilter = new AttributeFilter(ff.getAttrName() + SearchEngineImpl.getSuffix(ff));
			attrFilter.assign(ff);
			filters.add(attrFilter);
		}
		return filters;
	}

	private List<AttributeFilter> getFacetAttrFilters(QueryMetaData qmd)
	{
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		Collection<FacetPath> facetPaths = qmd.getFacetPaths();
		if (facetPaths != null && facetPaths.size() > 0 && searchableObject != null)
		{
			SearchableObject facetSO = searchableObject;
			if (facetSO != null)
			{
				Collection<AttributeFilter> facetFilters = FacetManager.getFilters(facetSO, facetPaths);

				for (AttributeFilter ff : facetFilters)
				{
					ff = new AttributeFilter(ff.getAttrName() + SearchEngineImpl.getSuffix(ff), 
									ff.getAttrbuteType(), 
									"\"" + ff.getAttrValue() + "\"", 
									ff.getOperator());
					filters.add(ff);
				}
			}
		}
		return filters;
	}

	public SolrSearchHitsImpl search() throws SearchException
	{
		try
		{
			SolrServer server = engine.getSolrServer(searchableObject);
			SolrQuery solrQuery = getQuery(qmd);

			return createSearchHits(server.query(solrQuery));
		}
		catch (Throwable sse)
		{
			return createErrorHits(sse);
		}
	}

	private SolrSearchHitsImpl createErrorHits(Throwable t) throws SearchException
	{
		SolrSearchHitsImpl hits = null;
		HitsMetaDataImpl hmd = new HitsMetaDataImpl();
		hits = new SolrSearchHitsImpl(hmd);
		hits.setEngineId(getEngineId());
		hmd.setQueryMetaData(qmd);

		hmd.setError(true);
		hmd.setErrorMessage(t.getLocalizedMessage());
		hmd.setHits(0);
		t.printStackTrace();
		return hits;
	}

	public SolrDocument getDocument(SearchableObject object, String field, String value)
	{
		SolrDocument sd = null;
		try
		{
			SolrServer server = engine.getSolrServer(object);
			SolrQuery solrQuery = new SolrQuery();
			AttributeFilter fieldFilter = new AttributeFilter(field, value, null, Constants.OPERATOR_EQS);
			addFilter(solrQuery, fieldFilter);

			QueryResponse response = server.query(solrQuery);
			long numberFound = response.getResults().getNumFound();
			if (numberFound >= 1)
			{
				if (numberFound > 1)
				{
					System.err.println("More than one result returned from the engine, the first one returned from this method");
				}
				sd = response.getResults().get(0);
			}
		}
		catch (Throwable sse)
		{
			sse.printStackTrace();
		}
		return sd;
	}

	private SolrSearchHitsImpl createSearchHits(QueryResponse res) throws SearchException
	{
		SolrSearchHitsImpl hits = null;
		HitsMetaDataImpl hmd = new HitsMetaDataImpl();
		hmd.setQueryMetaData(qmd);

		if (res != null)
		{
			hits = new SolrSearchHitsImpl(res, searchableObject, hmd);
			hmd.setHits(Integer.valueOf("" + res.getResults().getNumFound()));
		}
		else
		{
			hits = new SolrSearchHitsImpl(hmd);
		}

		hits.setEngineId(getEngineId());
		hmd.setHits(Integer.valueOf("" + res.getResults().getNumFound()));
		return hits;
	}

	private void installSecurityFilters(SolrQuery solrQuery) throws SearchSecurityException
	{
		Object securityPlugin = searchableObject.getSearchPlugin();
		if (securityPlugin == null || !(securityPlugin instanceof Securable))
		{
			return; // public, no security filters
		}

		List<String> secureAttrs = new ArrayList<String>();
		Securable securable = (Securable) securityPlugin;
		if (securable.isAclEnabled())
		{
			List<String> keys = securable.getSecurityKeys();
			StringBuffer securityKeys = new StringBuffer();
			for (String key : keys)
			{
				securityKeys.append(key);
			}

			if (securityKeys.length() == 0)
			{
				securityKeys.append("NO_ACCESS");
			}

			addFilter(solrQuery, new AttributeFilter(Constants.ACL_KEY, null, securityKeys.toString(), Constants.OPERATOR_CONTAINS));
			secureAttrs.add(Constants.ACL_KEY);
		}

		Iterator<AttributeDefinition> iter = searchableObject.getDocumentDef().getAttrDefs().iterator();
		while (iter.hasNext())
		{
			AttributeDefinition ff = iter.next();
			if (ff.isSecure() && !ff.getName().equals(Constants.ACL_KEY))
			{
				List<String> keys = securable.getSecureAttrKeys(ff.getName());
				StringBuffer securityKeys = new StringBuffer();
				for (String key : keys)
				{
					securityKeys.append(key);
				}

				if (securityKeys.length() == 0)
				{
					securityKeys.append("NO_ACCESS");
				}

				addFilter(solrQuery, new AttributeFilter(IndexerImpl.SECURITY_ATTR_PREFIX + ff.getName(), 
								null, securityKeys.toString(), 
								Constants.OPERATOR_CONTAINS));
				secureAttrs.add(ff.getName());
			}
		}
	}


	void deleteByQuery(SearchableObject object, List<AttributeFilter> filters)
	{
		try
		{
			if (filters == null || filters.size() == 0)
			{
				return;
			}

			SolrServer server = engine.getSolrServer(object);
			filters = convertFilters(filters);
			StringBuffer query = new StringBuffer();

			for (int i = 0; i < filters.size(); i++)
			{
				AttributeFilter ff = filters.get(i);
				query.append(ff.getAttrName()).append(":").append("\"").append(ff.getAttrValue()).append("\"");
				if (i == filters.size() - 1)
				{
					break;
				}
				else
				{
					query.append(" AND ");
				}
			}

			UpdateResponse resp = server.deleteByQuery(query.toString());
			System.err.println("Delete " + object.getName() + " with query " + query + " status : " + resp.getStatus());
			server.commit();
		}
		catch (SolrServerException sse)
		{
			// TODO: Add catch code
			sse.printStackTrace();
		}
		catch (IOException ioe)
		{
			// TODO: Add catch code
			ioe.printStackTrace();
		}
	}
}
