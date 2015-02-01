package org.sixstreams.search.query;

import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.Searcher;

public abstract class AbstractSearcher
   implements Searcher
{
   private HitsMetaData hmd = new HitsMetaDataImpl();

   /**
    * Returns hits meta data object.
    */
   public HitsMetaData getHitsMetaData()
   {
      return hmd;
   }
}
