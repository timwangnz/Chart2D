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
    * Indexes a document.
    *
    * @param document to be indexed.
     * @throws org.sixstreams.search.IndexingException
    */
   void indexDocument(IndexableDocument document)
      throws IndexingException;
   
   
   void indexBatch(List<IndexableDocument> document)
   throws IndexingException;
   /**
    * Sets Searchable Object for this indexer
    * @param searchableObject
     * @throws org.sixstreams.search.IndexingException
    */
   void setSearchableObject(SearchableObject searchableObject)
      throws IndexingException;

   /**
    * Closes the indexer. Clean up call after indexing.
     * @throws org.sixstreams.search.IndexingException
    */
   void close()
      throws IndexingException;

   /**
    * Creates an index store.
     * @throws org.sixstreams.search.IndexingException
    */
   void createIndex()
      throws IndexingException;

   /**
    * Deletes the index store permanently
    */
   void deleteIndex();
}
