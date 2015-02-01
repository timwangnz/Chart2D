package org.sixstreams.search.solr.query;

import java.util.HashMap;
import java.util.List;

import org.apache.solr.client.solrj.response.FacetField;
import org.sixstreams.Constants;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.AbstractSearcher;
import org.sixstreams.search.query.HitsMetaDataImpl;
import org.sixstreams.search.query.IndexedDocumentImpl;
import org.sixstreams.search.solr.SolrEngineImpl;
import org.sixstreams.search.util.ContextFactory;

public class ObjectSearcher extends AbstractSearcher
{
	private SolrEngineImpl engine;

	public ObjectSearcher(SolrEngineImpl engine)
	{
		this.engine = engine;
	}

	@Override
	public SearchHits search(QueryMetaData queryMetaData) throws SearchException
	{
		SearchContext ctx = ContextFactory.getSearchContext();
		ObjectSearcherImpl impl = new ObjectSearcherImpl(engine, -1L, queryMetaData, ctx.getSearchableObject());
		SolrSearchHitsImpl hits = impl.search();
		if (hits.getFacetFields() != null)
		{
			updateHitsMetaData(hits);
		}
		return hits;
	}

	@Override
	public IndexedDocument createIndexedDocument(SearchContext ctx, List<AttributeValue> attributes)
	{
		return new IndexedDocumentImpl(ctx, attributes);
	}

	@Override
	public void deleteObjectsByFilters(SearchableObject object, List<AttributeFilter> filters)
	{
		ObjectSearcherImpl searcher = new ObjectSearcherImpl(engine);
		searcher.deleteByQuery(object, filters);
	}

	private HashMap<String, Integer> getValueCountsFromFacetNode(FacetField facetField)
	{
		HashMap<String, Integer> valueCounts = new HashMap<String, Integer>();
		if (facetField.getValues() != null)
		{
			for (FacetField.Count count : facetField.getValues())
			{
				valueCounts.put(count.getName(), new Integer("" + count.getCount()));
			}
		}
		return valueCounts;
	}

	public void updateHitsMetaData(SolrSearchHitsImpl hits)
	{
		HitsMetaDataImpl hmd = (HitsMetaDataImpl) hits.getHitsMetaData();
		HashMap<String, HashMap<String, Integer>> facetsValueCounts = new HashMap<String, HashMap<String, Integer>>();
		for (FacetField facetField : hits.getFacetFields())
		{
			HashMap<String, Integer> valueCounts = getValueCountsFromFacetNode(facetField);
			int lastIndexOfUnderscore = facetField.getName().lastIndexOf(Constants.UNDERSCORE);
			if (lastIndexOfUnderscore != -1)
			{
				String fieldName = facetField.getName().substring(0, lastIndexOfUnderscore);
				facetsValueCounts.put(fieldName, valueCounts);
			}
			else
			{
				facetsValueCounts.put(facetField.getName(), valueCounts);
			}
		}
		hmd.setFacetsValueCounts(facetsValueCounts);
	}
}
