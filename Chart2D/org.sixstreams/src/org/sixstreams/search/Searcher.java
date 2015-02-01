package org.sixstreams.search;

import java.util.List;

import org.sixstreams.search.meta.SearchableObject;

/**
 * Searcher is responsible for performing searches. The implementation is created
 * by an search engine instance which is implemented for a specific search engine.
 *
 */
public interface Searcher
{

   /**
    * Retruns the hit meta data per search.
    * @return HitMetaData meta data of a result set.
    */
   HitsMetaData getHitsMetaData();


   /**
    * Returns a search hits for a given query. @see QueryMetaData
    * @param queryMetaData the query data
    * @return SearchHits for the query. Returns null if fails by underline search
    * engine.
    */
   SearchHits search(QueryMetaData queryMetaData)
      throws SearchException;

   /**
    * Creates an engine implementation of indexed document based on a list attribute values.
    * @param ctx the runtime search context and a searchable object must be assigned to
    * the context. If not, an IllegalStateException will be thrown.
    * @param attributes custom attribute values hashed agaist field attribute name.
    * @return an indexed document.
    * @throws IllegalStateException if ctx is not assigned with a searchable object.
    */

   IndexedDocument createIndexedDocument(SearchContext ctx, List<AttributeValue> attributes);


   void deleteObjectsByFilters(SearchableObject object, List<AttributeFilter> filters);
}
//
