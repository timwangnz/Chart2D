package org.sixstreams.search.query;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.facet.Facet;
import org.sixstreams.search.facet.FacetDef;
import org.sixstreams.search.facet.FacetEntry;
import org.sixstreams.search.meta.SearchableGroup;

/**
 * HitsMeta data defines the results from a search operation.
 */
public class HitsMetaDataImpl implements HitsMetaData, Serializable
{
	// private long mHitsPerPage = Constants.DEFAULT_PAGE_SIZE;
	private long searchHits = -1;
	// private long mPage = 1;

	private long timeSpent = 0;

	private String keywords;
	private boolean error;
	private String errorMessage;
	private List<SearchableGroup> searchableGroups;
	private HashMap<String, HashMap<String, Integer>> facetsValueCounts;
	private QueryMetaDataImpl queryMetaData;

	/**
	 * @inheritDoc
	 */
	public long getHitsPerPage()
	{
		return queryMetaData.getPageSize();
	}

	/**
	 * @inheritDoc
	 */
	public long getHits()
	{
		return searchHits;
	}

	/**
	 * @inheritDoc
	 */
	public long getPages()
	{
		if (searchHits > 0 && getHitsPerPage() != 0)
		{
			return (searchHits / getHitsPerPage()) + (searchHits % getHitsPerPage() == 0 ? 0 : 1);
		}
		return 0;
	}

	/**
	 * Sets the time spent in ms for a given search. Internal use only.
	 * 
	 * @param timeSpent
	 */
	public void setTimeSpent(long timeSpent)
	{
		this.timeSpent = timeSpent;
	}

	/**
	 * @inheritDoc
	 */
	public long getTimeSpent()
	{
		return timeSpent;
	}

	/**
	 * @inheritDoc
	 */
	public long getOffset()
	{
		return queryMetaData.getOffset();
	}

	/**
	 * @inheritDoc
	 */
	public String getQuery()
	{
		return queryMetaData.getQueryString();
	}

	/**
	 * @inheritDoc
	 */
	public void setError(boolean error)
	{
		this.error = error;
	}

	/**
	 * @inheritDoc
	 */
	public boolean isError()
	{
		return error;
	}

	/**
	 * @inheritDoc
	 */
	public void setErrorMessage(String errorMessage)
	{
		this.error = true;
		this.errorMessage = errorMessage;
	}

	/**
	 * @inheritDoc
	 */
	public String getErrorMessage()
	{
		return errorMessage;
	}

	/**
	 * Sets the searchable groups for this search. Internal use only.
	 * 
	 * @param searchableGroups
	 */
	public void setSearchableGroups(Collection<SearchableGroup> searchableGroups)
	{
		this.searchableGroups = new ArrayList<SearchableGroup>(searchableGroups);
	}

	/**
	 * @inheritDoc
	 */
	public Collection<SearchableGroup> getSearchableGroups()
	{
		return searchableGroups;
	}

	/**
	 * Sets the estimated total number of hits for the query performed. Internal
	 * use only.
	 * 
	 * @param hits
	 */
	public void setHits(long hits)
	{
		this.searchHits = hits;
	}

	/**
	 * Sets the alternate keywords for the query string. Internal use only.
	 * 
	 * @param keywords
	 */
	public void setAltKeywords(String keywords)
	{
		this.keywords = keywords;
	}

	/**
	 * @inheritDoc
	 */
	public String getAltKeywords()
	{
		return keywords;
	}

	public List<Facet> getFacets()
	{
		if (facetsValueCounts != null)
		{
			ArrayList<Facet> facets = new ArrayList<Facet>();
			for (String attrName : facetsValueCounts.keySet())
			{
				HashMap<String, Integer> valueCounts = facetsValueCounts.get(attrName);
				if (valueCounts != null)
				{
					FacetDef facetDef = new FacetDef(null, attrName, attrName);
					Facet facet = new Facet(facetDef);
					for (String value : valueCounts.keySet())
					{
						Integer count = valueCounts.get(value);
						if (count != null)
						{
							FacetEntry entry = new FacetEntry(facet, attrName, value, count);
							facet.addEntry(entry);
						}
					}
					facets.add(facet);
				}
			}
			return facets;
		}
		return Collections.emptyList();
	}

	/**
	 * @inheritDoc
	 */
	public QueryMetaData getQueryMetaData()
	{
		return this.queryMetaData;
	}

	/**
	 * Sets the query metadata for the search. Internal use only.
	 * 
	 * @param qmd
	 */
	public void setQueryMetaData(QueryMetaData qmd)
	{
		this.queryMetaData = (QueryMetaDataImpl) qmd; // this qmd can change
														// later
	}

	/**
	 * Sets the facets value counts from SES. Internal use only.
	 * 
	 * @param facetsValueCounts
	 */
	public void setFacetsValueCounts(HashMap<String, HashMap<String, Integer>> facetsValueCounts)
	{
		this.facetsValueCounts = facetsValueCounts;
	}

	public List<AttributeFilter> getFilters()
	{
		return queryMetaData.getAssignedFilters();
	}
}
