package org.sixstreams.search;

import java.util.Collection;
import java.util.List;

import org.sixstreams.search.facet.FacetPath;
import org.sixstreams.search.query.SearchGroup;

/**
 * QueryMetaData defines the input meta data of a search query. The user can
 * specify the query string, search groups, page size, facet selections, etc, that
 * are associated with a particular query. This object is passed in as a
 * parameter to the runQuery() method of SearchCtrl class.
 */

public interface QueryMetaData
{
   public static final String DESC = "desc";
   public static final String ASC = "asc";

   /**
    * Sets the query string for this query
    * @param queryStr query string
    */
   void setQueryString(String queryStr);

   /**
    * Returns the query string for this query
    * @return String query string
    */
   String getQueryString();

   /**
    * Add search groups used for this query
    * @param sgs array of SearchGroup objects
    */
   void addSearchGroups(List<SearchGroup> sgs);

   /**
    * Add search group used for this query
    * @param sgs array of SearchGroup objects
    */
   void addSearchGroup(SearchGroup sgs);

   /**
    * Returns the search groups used for this query
    * @return array of SearchGroup objects
    */
   List<SearchGroup> getSearchGroups();

   /**
    * Sets the search object that the query will be filtered by
    * @param soName - the search object name to filter query by
    *                 Set to null to clear.
    */
   void setSOName(String soName);

   /**
    * Returns the search object name used to filter the query
    * @return soName
    */
   String getSOName();

   /**
    * Sets the page size to be used for this query
    * @param size the page size.
    */
   void setPageSize(int size);

   /**
    * Returns the page size used for this query
    * @return int size
    */
   int getPageSize();

   /**
    * Sets the page number to be retrieved for this query
    * @param page page position for this request.
    */
   void setOffset(long offset);

   /**
    * Returns the page number retrieved for this query
    * @return int page
    */
   long getOffset();

   /**
    * Sets the filters to be used for this advanced search query
    * @param attrName the attribute name
    * @param filterValue the filter value
    * @param filterOp the filter operator of the filter. The value is engine
    * dependent.
    */
   void addFilter(String attrName, String attrType, Object filterValue, String filterOp);
   void addRangeFilter(String attrName, String attrType, Object loValue, Object hiValue);
   
   void addFilter(AttributeFilter filter);

   /**
    * Returns the a list of AttributeFilter objects hashed by field name. Filters are
    * used for this advanced search queries.
    * @return a list of AttributeFilter objects
    */
   List<AttributeFilter> getAssignedFilters();

   void addFacetName(String facetName);
   List<String> getFacetNames();
   /**
    * Removes all the filters added for this queryMetaData
    */
   void removeAllFilters();

   /**
    * Clears all facet paths.
    */
   void clearFacetPaths();

   public void clearAllFacetSelections();

   /**
    * @param rootFacetName
    */
   public void clearFacetSelections(String rootFacetName);

   /**
    * Selects a facet value for the leaf facet of a root facet.
    * @param rootFacetName - the name of the root facet.
    * @param value - the value selected for the current leaf facet.
    */
   void selectFacetValue(String rootFacetName, String value);

   /**
    * Removes the leaf facet's selected value
    * @param rootFacetName - the name of the root facet.
    */
   void removeFacetValue(String rootFacetName);

   /**
    * Returns the facet paths used for this query
    * @return array of FacetPath objects
    */
   Collection<FacetPath> getFacetPaths();

   /**
    * Sets the maximum number of facet values each facet should return.
    * @param maxFacetValues - max number of values for each facet. -1 for all values (default).
    */
   void setMaxFacetValues(int maxFacetValues);

   /**
    * Gets the maximum number of facet values each facet should return.
    * @return - max number of values for each facet. -1 for all values (default).
    */
   int getMaxFacetValues();

   /**
    * Sets whether the facet functionality is enabled. (default is true)
    * @param enable - boolean
    */
   void enableFacets(boolean enable);

   /**
    * Returns whether facets are enabled or not.
    * @return boolean
    */
   boolean isFacetsEnabled();

   /**
    * Sets order by attribute for the query.
    * @param attrName name of the attributed for sorting
    * @param dir direction to sort, asc or desc. Default is desc.
    */
   void setOrderBy(String attrName, String dir);

   /**
    * Returns order by attribute name.
    * @return order by attribute name
    */
   String getOrderBy();

   /**
    * Return order by direction.
    * @return order by direction, DESC or ASC
    */
   String getOrderByDir();

   /**
    * Returns the language for the query. If null, the user's default language setting
    * will be used
    * @return ISO 639-1 standard language code
    */
   String getLanguage();

   /**
    * Sets the language for the query, this value overrides the user's default
    * language setting
    * @param ISO 639-1 standard language code
    */
   void setLanguage(String language);


   public void setFacetPath(String rootFacetName, FacetPath path);
   
   
}
