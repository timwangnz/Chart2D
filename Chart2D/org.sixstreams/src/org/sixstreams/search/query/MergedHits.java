package org.sixstreams.search.query;

import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;

/**
 * This is an internal class, should not be used directly by developers. SearchHits
 * interface should be used instead.
 */
public class MergedHits
   extends SearchHitsImpl
{
   public MergedHits(SearchHits hits, HitsMetaDataImpl hmd)
      throws SearchException
   {
      super(hmd);

      HitsMetaData mergedMetaData = hits.getHitsMetaData();
      hmd.setAltKeywords(mergedMetaData.getAltKeywords());
      hmd.setHits(mergedMetaData.getHits());

      for (int i = 0; i < hits.getCount(); i++)
      {
         IndexedDocument doc = hits.getDocument(i);
         addDocument(doc);
      }
   }
}
