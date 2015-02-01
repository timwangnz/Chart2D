package org.sixstreams.search.query;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.meta.SearchableObject;


/**
 * Implementation for SearchHits. Holds HitsMetaData and a list of IndexedDocuments.
 */
public class SearchHitsImpl
   implements SearchHits
{
   /**
    * Constructs a hits from ses results
    * @param hmd search meta data.
    */
   public SearchHitsImpl(HitsMetaData hmd)
   {
      this.hitsMetaData = hmd;
   }

   /**
    * Returns ith document in the hit.
    * @param i sequence of the document.
    * @return an indexed document.
    */
   public IndexedDocument getDocument(int i)
   {
      return indexedDocuments.get(i);
   }

   /**
    * Adds a document to the hits. This is used internally by searcher.
    * @param doc
    */
   public void addDocument(IndexedDocument doc)
   {
      indexedDocuments.add(doc);
   }

   /**
    * Returns count in this mSearchHits. This is not total hits. Just number of items
    * returned.
    * @return number of items in this mSearchHits.
    */
   public int getCount()
   {
      return indexedDocuments.size();
   }

   /**
    * Returns the hits meta data.
    * @return search hits metadata.
    */
   public HitsMetaData getHitsMetaData()
   {
      return hitsMetaData;
   }

   /**
    * Returns list of documents.
    * @return the indexed documents.
    */
   public List<IndexedDocument> getIndexedDocuments()
   {
      return indexedDocuments;
   }

   //get hits for each seachable object. This is called when post query process
   //is needed

   /**
    * Returns a subset of the results per searchable object. this is for internal
    * use only.
    *
    * @param searchableObject    the searchable object
    * @return                    a search hits that contains documents belong
    * to the searchable object.
    */
   public SearchHitsImpl getSearchHits(SearchableObject searchableObject)
   {
      SearchHitsImpl childHits = new SearchHitsImpl(hitsMetaData);
      childHits.searchableObject = searchableObject;
      for (IndexedDocument doc: indexedDocuments)
      {
         if (searchableObject.equals(doc.getSearchableObject()))
         {
            childHits.addDocument(doc);
         }
      }
      return childHits;
   }

   //once the post query process is done,
   //some of the documents might have been changed in the post query process
   //handle deleted object
   //updated document should be fine

   /**
    * For internal use only. This method is called when a child hits is processed
    * by the post query processor.
    * @param childHits     the child hits processed by searchable object plug-in.
    */
   public void mergePostQueryChanges(SearchHitsImpl childHits)
   {
      SearchableObject obj = childHits.searchableObject;
      List<IndexedDocument> docs2BeRemoved = new ArrayList<IndexedDocument>();
      for (IndexedDocument doc: indexedDocuments)
      {
         if (obj.equals(doc.getSearchableObject()))
         {
            if (!childHits.indexedDocuments.contains(doc))
            {
               docs2BeRemoved.add(doc);
            }
         }
      }
      for (IndexedDocument doc: docs2BeRemoved)
      {
         indexedDocuments.remove(doc);
      }
   }

   /**
    * Remove documents from current serach hits. This can be used to remove
    * documents that are not suitable for display by the post query plug-in.
    * @param document   the indexed document to be removed from the hits.
    */
   public void removeDocument(IndexedDocument document)
   {
      if (indexedDocuments.contains(document))
      {
         indexedDocuments.remove(document);
      }
   }

   /* ------------------------ private memeber -------------------------------*/
   //store hits
   private List<IndexedDocument> indexedDocuments = new ArrayList<IndexedDocument>();
   private HitsMetaData hitsMetaData;
   private SearchableObject searchableObject;
   private List<AttributeValue> aggregatedValues = new ArrayList<AttributeValue>();

   public List<AttributeValue> getAggregatedAttributes()
   {
      return aggregatedValues;
   }

}
