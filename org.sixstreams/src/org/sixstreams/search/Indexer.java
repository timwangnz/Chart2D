package org.sixstreams.search;

import java.util.List;

import org.sixstreams.search.meta.SearchableObject;

/**
 * The <code>indexer</code> is responsible for indexing a document. It bridges between
 * an index engine and indexable documents.
 * <p>
 * A search engine should implement this interface with its internal index mechanism.
 */
public interface Indexer
{


   /**
    * Indexs a document.
    *
    * @param searchContext crawl time context.
    * @param document to be indexed.
    */
   void indexDocument(IndexableDocument document)
      throws IndexingException;
   
   
   void indexBatch(List<IndexableDocument> document)
   throws IndexingException;
   /**
    * Sets Searchable Object for this indexer
    * @param searchableObject
    */
   void setSearchableObject(SearchableObject searchableObject)
      throws IndexingException;

   /**
    * Closes the indexer. Clean up call after indexing.
    */
   void close()
      throws IndexingException;

   /**
    * Creates an index store.
    */
   void createIndex()
      throws IndexingException;

   /**
    * Deletes the index store permanently
    */
   void deleteIndex();
}
