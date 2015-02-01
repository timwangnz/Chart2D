package org.sixstreams.search;

import java.util.List;

/**
 * Search hits of a given search. This is returned by the search
 * engine upon a request of search.
 */
public interface SearchHits
{
   /**
    * Returns list of indexed documents in the hit list
    */
   List<IndexedDocument> getIndexedDocuments();

   List<AttributeValue> getAggregatedAttributes();

   /**
    * Returns ith document in the hit list
    * @param i index.
    */
   IndexedDocument getDocument(int i);

   /**
    * Returns number of documents returned. This is not the total
    * hits of the search, rather documents per page.
    * To obtain total hits, one can call HitsMetaData.getHits.
    */
   int getCount();

   /**
    * Adds document to the hits. This is used internally by the searcher
    * to constuct the list.
    *
    * @param doc an indexable document constructed from information retrieved
    * from index store.
    */
   void addDocument(IndexedDocument doc);

   /**
    * Returns meta data for this search hits.
    * @return meta data for this search.
    */
   HitsMetaData getHitsMetaData();
}
