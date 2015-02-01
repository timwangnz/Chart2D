package org.sixstreams.search.query;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchHits;

public class MergableSearchHitsImpl
   implements SearchHits
{
   private List<IndexedDocument> indexedDocuments = new ArrayList<IndexedDocument>();

   private List<AttributeValue> aggregatedAttributes = new ArrayList<AttributeValue>();

   public MergableSearchHitsImpl(QueryMetaData qmd)
   {
      super();
      hitsMetaData.setQueryMetaData(qmd);
   }

   public IndexedDocument getDocument(int i)
   {
      return indexedDocuments.get(i);
   }


   public int getCount()
   {
      return indexedDocuments.size();
   }

   public void addDocument(IndexedDocument p1)
   {

      this.indexedDocuments.add(p1);
   }

   public HitsMetaData getHitsMetaData()
   {
      return hitsMetaData;
   }

   public void setHitsMetaData(HitsMetaData hitsMetaData)
   {
      this.hitsMetaData = (HitsMetaDataImpl) hitsMetaData;
   }


   private HitsMetaDataImpl hitsMetaData = new HitsMetaDataImpl();


   public List<IndexedDocument> getIndexedDocuments()
   {
      return indexedDocuments;
   }

   public List<AttributeValue> getAggregatedAttributes()
   {
      return aggregatedAttributes;
   }
}
