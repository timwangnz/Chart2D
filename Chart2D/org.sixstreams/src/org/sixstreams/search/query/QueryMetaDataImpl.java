package org.sixstreams.search.query;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import org.sixstreams.Constants;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.RuntimeSearchException;
import org.sixstreams.search.facet.FacetPath;

public class QueryMetaDataImpl implements QueryMetaData, Serializable
{
	private static final long serialVersionUID = 1L;

	private List<SearchGroup> searchGroups = new ArrayList<SearchGroup>();
	private String queryString;
	private int pageSize = Constants.DEFAULT_PAGE_SIZE;
	private long offset = 1L;
	private List<AttributeFilter> attributeFilters = new ArrayList<AttributeFilter>();
	private String sortByFields;
	private String sortByDir;

	private HashMap<String, FacetPath> mapFacetPaths = new HashMap<String, FacetPath>();
	private int maxFacetValues = -1;
	private boolean facetsEnabled = true;
	private String soName;
	private String searchControls;
	private String language;

	private List<String> facetNames = new ArrayList<String>();

	public void addFacetName(String facetName)
	{
		if (facetNames.contains(facetName))
		{
			return;
		}
		facetNames.add(facetName);
	}

	public List<String> getFacetNames()
	{
		return facetNames;
	}

	/**
	 * @inheritDoc
	 */
	public void setQueryString(String queryStr)
	{
		queryString = queryStr;
	}

	/**
	 * @inheritDoc
	 */
	public String getQueryString()
	{
		return queryString;
	}

	/**
	 * @inheritDoc
	 */
	public void addSearchGroups(List<SearchGroup> sgs)
	{
		searchGroups.addAll(sgs);
	}

	public void addSearchGroup(SearchGroup sg)
	{
		searchGroups.add(sg);
	}

	/**
	 * @inheritDoc
	 */
	public List<SearchGroup> getSearchGroups()
	{
		return searchGroups;
	}

	/**
	 * @inheritDoc
	 */
	public void setSOName(String soName)
	{
		this.soName = soName;
	}

	/**
	 * @inheritDoc
	 */
	public String getSOName()
	{
		return soName;
	}

	/**
	 * @inheritDoc
	 */
	public void setPageSize(int size)
	{
		pageSize = size;
	}

	/**
	 * @inheritDoc
	 */
	public int getPageSize()
	{
		return pageSize;
	}

	/**
	 * @inheritDoc
	 */
	public void setOffset(long offset)
	{
		this.offset = offset;
	}

	/**
	 * @inheritDoc
	 */
	public long getOffset()
	{
		return offset;
	}

	public void addFilter(AttributeFilter attributeFileter)
	{
		attributeFilters.add(attributeFileter);
	}

	/**
	 * @inheritDoc
	 */
	public void addFilter(String fieldName, String attrType, Object filterValue, String filterOp)
	{
		addFilter(new AttributeFilter(fieldName, attrType, filterValue, filterOp));
	}
	
	public void addRangeFilter(String fieldName, String attrType, Object loValue, Object hiValue)
	{
		addFilter(new AttributeFilter(fieldName, attrType, loValue, hiValue));
	}
	/**
	 * @inheritDoc
	 */
	public void removeAllFilters()
	{
		attributeFilters.clear();
	}

	/**
	 * @inheritDoc
	 */
	public List<AttributeFilter> getAssignedFilters()
	{
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		filters.addAll(attributeFilters);
		return filters;
	}

	/**
	 * @inheritDoc
	 */
	public Collection<FacetPath> getFacetPaths()
	{
		return mapFacetPaths.values();
	}

	/**
	 * @inheritDoc
	 */
	public void clearFacetPaths()
	{
		mapFacetPaths.clear();
	}

	/**
	 * @inheritDoc
	 */
	public void selectFacetValue(String rootFacetName, String value)
	{
		FacetPath path = mapFacetPaths.get(rootFacetName);
		if (path != null)
		{
			path.select(value);
		}
		else
		{
			throw new RuntimeException("No facet found for " + rootFacetName);
		}
	}

	public void clearAllFacetSelections()
	{
		for (FacetPath path : mapFacetPaths.values())
		{
			if (path.getSelections().size() > 0)
			{
				path.getSelections().clear();
			}
		}
	}

	public void clearFacetSelections(String rootFacetName)
	{
		FacetPath path = mapFacetPaths.get(rootFacetName);
		if (path != null)
		{
			if (path.getSelections().size() > 0)
			{
				path.getSelections().clear();
			}

		}
	}

	/**
	 * @inheritDoc
	 */
	public void removeFacetValue(String rootFacetName)
	{
		FacetPath path = mapFacetPaths.get(rootFacetName);
		if (path != null)
		{
			if (path.getSelections().size() > 0)
			{
				path.removeSelection();
			}
			else
			{
				throw new RuntimeSearchException("Cannot remove facet value, Root Facet with name '" + rootFacetName + "' has no selections to remove.");
			}
		}
		else
		{
			throw new RuntimeSearchException("Root Facet with name '" + rootFacetName + "' does not exist.");
		}
	}

	/**
	 * Gets the state of the facet defined by the root facet name. Internal use
	 * only
	 * 
	 * @param rootFacetName
	 * @return FacetState
	 */
	public FacetPath getFacetPath(String rootFacetName)
	{
		return mapFacetPaths.get(rootFacetName);
	}

	/**
	 * Sets the state of the facet defined by the root facet name. Internal use
	 * only
	 * 
	 * @param rootFacetName
	 * @param path
	 */
	public void setFacetPath(String rootFacetName, FacetPath path)
	{
		mapFacetPaths.put(rootFacetName, path);
	}

	/**
	 * @inheritDoc
	 */
	public void setMaxFacetValues(int maxFacetValues)
	{
		this.maxFacetValues = maxFacetValues;
	}

	/**
	 * @inheritDoc
	 */
	public int getMaxFacetValues()
	{
		return maxFacetValues;
	}

	/**
	 * @inheritDoc
	 */
	public void enableFacets(boolean enable)
	{
		facetsEnabled = enable;
	}

	/**
	 * @inheritDoc
	 */
	public boolean isFacetsEnabled()
	{
		return facetsEnabled;
	}

	/**
	 * @inheritDoc
	 */
	public void setSearchControls(String sesSearchControls)
	{
		this.searchControls = sesSearchControls;
	}

	/**
	 * @inheritDoc
	 */
	public String getSearchControls()
	{
		return searchControls;
	}

	/**
	 * @inheritDoc
	 */
	public void setLanguage(String language)
	{
		this.language = language;
	}

	/**
	 * @inheritDoc
	 */
	public String getLanguage()
	{
		if (language == null || language.isEmpty())
		{
			language = Locale.ENGLISH.getLanguage();
		}

		return language;
	}

	//
	// internal fitlers are added automatically so that mFilters can be
	// stored, reused etc.
	//

	public List<AttributeFilter> getInternalFilters()
	{
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		/*
		 * // apply extra filters if (mSoName != null) { filters.add(new
		 * AttributeFilter(Constants.SO_NAME, String.class.getName(), mSoName,
		 * Constants.OPERATOR_EQS)); } //TODO handle multi values if (mTags !=
		 * null && mTags.size() != 0) { filters.add(new
		 * AttributeFilter(Constants.ATTR_TAGS, Constants.STRING_ARRAY,
		 * mTags.get(0), Constants.OPERATOR_EQS)); }
		 */
		return filters;
	}

	public void setOrderBy(String attrName, String dir)
	{
		this.sortByFields = attrName;
		this.sortByDir = dir == null ? DESC : dir;
	}

	public String getOrderBy()
	{
		return sortByFields;
	}

	public String getOrderByDir()
	{
		return sortByDir;
	}

	public String toString()
	{
		return "Query:" + queryString + "\n" + "With filters :" + attributeFilters + "\n" + "Sort by: " + sortByFields + " " + sortByDir + "\n" + "Object: " + this.soName;
	}
}
