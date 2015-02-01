package org.sixstreams.search;

import java.util.Collection;
import java.util.List;

import org.sixstreams.search.facet.Facet;
import org.sixstreams.search.meta.SearchableGroup;

/**
 * HitsMetaData defines meta data of a search query. The instance can be created and passed
 * to a search engine, where user can specify
 * filters, hits per page etc. On return, the instance contains
 * information such as number of hits, time spent, and other meta data
 * of the search results, including spelling, error message etc.
 *  @since   11.gr2
 */
public interface HitsMetaData
{

   /**
    * Returns the number of entries per page
    * @return int - entries per page
    */
   long getHitsPerPage();


   /**
    * Returns the estimated total number of hits for the query performed
    * This is not the number of hits returned to the user
    * @return int - number of hits.
    */
   long getHits();

   /**
    * Returns the number of pages
    * @return int - number of pages
    */
   long getPages();

   /**
    * Returns the time spent in ms for a given search
    * @return long - time spent
    */
   long getTimeSpent();

   /**
    * Returns the offset
    * @return int - starting row
    */
   long getOffset();


   /**
    * Returns the filters used for the query
    * @return List - filters
    */
   List<AttributeFilter> getFilters();


   /**
    * Returns the query string for the search
    * @return String - query string
    */
   String getQuery();

   /**
    * Returns the query metadata for the search
    * @return QueryMetaData - query metadata object
    */
   QueryMetaData getQueryMetaData();

   /**
    * Flags that the search resulted in error
    * @param error
    */
   void setError(boolean error);


   /**
    * Returns the error status for the search
    * @return boolean - whether the search resulted in an error
    */
   boolean isError();

   /**
    * Sets the error message for this search, used by the searcher. Internal use only.
    * @param errorMessage
    */
   void setErrorMessage(String errorMessage);

   /**
    * Returns the error message for this search
    * @return String - error message if any
    */
   String getErrorMessage();

   /**
    * Returns the searchable groups for this search
    * @return SearchableGroups searchable groups
    */
   Collection<SearchableGroup> getSearchableGroups();

   /**
    * Returns comma delimited alternate keywords for the query string used
    * @return String alternate keywords
    */
   String getAltKeywords();

   /**
    * Returns the facets applicable to the searchable object
    * @return Facets
    */
   List<Facet> getFacets();

   public void setQueryMetaData(QueryMetaData qmd);

   public void setTimeSpent(long l);
}
