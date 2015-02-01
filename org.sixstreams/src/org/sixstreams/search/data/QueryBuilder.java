package org.sixstreams.search.data;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.query.QueryMetaDataImpl;
import org.sixstreams.search.query.SearchGroup;

public class QueryBuilder
{
	private QueryMetaData qmd;

	public QueryBuilder()
	{
		qmd = new QueryMetaDataImpl();
	}

	// TODO
	public QueryBuilder(String urlQuery)
	{
		qmd = new QueryMetaDataImpl();
	}

	public QueryBuilder enableFacet(boolean bValue)
	{
		qmd.enableFacets(bValue);
		return this;
	}

	public QueryBuilder setLimit(int limit)
	{
		qmd.setPageSize(limit);
		return this;
	}

	public QueryBuilder setOffset(int offset)
	{
		qmd.setOffset(offset);
		return this;
	}

	public QueryBuilder setQuery(String query)
	{
		qmd.setQueryString(query);
		return this;
	}

	public QueryBuilder setOrderBy(String orderBy)
	{
		if (orderBy != null)
		{
			String[] orderByElements = orderBy.split(",");
			String dir = QueryMetaData.ASC;
			if (orderByElements.length == 2)
			{
				dir = orderByElements[1];
				orderBy = orderByElements[0];
			}
			qmd.setOrderBy(orderBy, dir);
		}
		return this;
	}

	public QueryBuilder addRangeFilter(String attrName, Number hiValue, Number lowValue, String attrType)
	{
		qmd.addRangeFilter(attrName, attrType, hiValue, lowValue);
		return this;
	}
	
	public QueryBuilder addFilter(String attrName, Object filterValue, String attrType, String operator)
	{
		qmd.addFilter(attrName, attrType, filterValue, operator);
		return this;
	}
	
	public QueryBuilder setFilters(List<AttributeFilter> filters)
	{
		for (AttributeFilter filter : filters)
		{
			qmd.addFilter(filter);
		}
		return this;
	}

	public QueryBuilder setRequestFacets(List<String> facets)
	{
		if (facets != null)
		{
			for (String facetName : facets)
			{
				qmd.addFacetName(facetName);
			}
		}
		return this;
	}

	public QueryBuilder setObjectType(String objectName)
	{
		List<SearchGroup> groups = new ArrayList<SearchGroup>();
		groups.add(new SearchGroup(objectName, -1L));
		qmd.addSearchGroups(groups);
		qmd.setSOName(objectName);
		return this;
	}

	public QueryMetaData create()
	{
		return qmd;
	}
}
