package org.sixstreams.search.solr.query;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.SearchHitsImpl;

import org.apache.solr.client.solrj.response.FacetField;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;

public class SolrSearchHitsImpl
   extends SearchHitsImpl
{
   private long engineId;
   private List<FacetField> facetFields;


   public SolrSearchHitsImpl(HitsMetaData hmd)
      throws SearchException
   {
      super(hmd);
   }

   public SolrSearchHitsImpl(QueryResponse res, SearchableObject searchableObject, HitsMetaData hmd)
      throws SearchException
   {
      super(hmd);
      Map<String, Map<String, List<String>>> highlights = res.getHighlighting();
      Iterator<SolrDocument> iter = res.getResults().iterator();
      while (iter.hasNext())
      {
         SolrDocument hit = (SolrDocument) iter.next();
         SolrIndexedDocumentImpl doc = new SolrIndexedDocumentImpl(searchableObject, hit, highlights);
         addDocument(doc);
      }
      facetFields = res.getFacetFields();
   }

   public List<FacetField> getFacetFields()
   {
      return facetFields;
   }

   public void setFacetFields(List<FacetField> facetFields)
   {
      this.facetFields = facetFields;
   }

   public void setEngineId(long engineId)
   {
      this.engineId = engineId;
   }

   public long getEngineId()
   {
      return engineId;
   }
}
