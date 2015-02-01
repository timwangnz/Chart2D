package org.sixstreams.search;

import org.sixstreams.search.meta.SearchableObject;


/**
 * Abstraction for a search engine. All the search engine plug-in must
 * implment this interface. The implemenation serves as a factory or container
 * for search related entities such as indexer, searcher, and crawler.
 * <p>Each searchable object can be associated with particular search engine.
 * This allows multiple search engines to be used in AppSearch.
 *
 */
public interface SearchEngine
{
   Administrator getAdministrator();

   /**
    * Returns human readable description for this search engine
    * @return a desicrtion for this search engine.
    */
   String getDescription();

   /**
    * Returns a searcher that can be used to query into its index store.
    * @return Searcher an implementation for this search engine.
    */
   Searcher getSearcher();

   /**
    * Returns a crawler implemenation
    * @return Crawler an implementation of this search engine.
    */
   Crawler getCrawler();

   /**
    * Returns an indexer implemenation
    * @return Indexer an implementation of this search engine.
    */
   Indexer getIndexer();

   /**
    * Creates a new indexable document instance.
    * @param searchableObject meta data for creating this instance.
    * @return instance of IndexableDocument, implemented for this search engine.
    */
   IndexableDocument createIndexableDocument(SearchableObject searchableObject);
   
   /**
    * To clean up any resources before shutdown
    */
   void cleanup();
}
