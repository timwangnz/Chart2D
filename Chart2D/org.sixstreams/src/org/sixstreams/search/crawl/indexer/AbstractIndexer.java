package org.sixstreams.search.crawl.indexer;

import org.sixstreams.search.Indexer;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.meta.SearchableObject;

/**
 * Abstract indexer to be extended by all search engine that needs to be
 * plugged into framework.
 */
public abstract class AbstractIndexer
   implements Indexer
{
   public AbstractIndexer clone()
   {
      return null;
   }

   public boolean isBusy()
   {
      return false;
   }

   public void setSearchableObject(SearchableObject searchableObject)
   {
      //no op
   }

   public void close()
   {
      //no op
   }

   public void deleteDocument(String url)
      throws SearchException
   {

   }

   public void createIndex()
   {
      //no op
   }

   public void deleteIndex()
   {
      //no op
   }
}
