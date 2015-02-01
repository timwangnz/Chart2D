package org.sixstreams.search.suggestions;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.sixstreams.search.Document;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.util.AuditingUtil;


public class AutoSuggestions
{
   static HashMap<String, AutoSuggestion> cache = new HashMap<String, AutoSuggestion>();
   private static AutoSuggestions manager = new AutoSuggestions();
   private long cacheHits = 0;
   private long totalIndexed = 0;
   private long totalHits = 1;
   private long totalObject = 0;
   
   private long batchSize = 200;
   private PersistenceManager pm = new PersistenceManager();

   private AutoSuggestions()
   {

   }

   public static void populateAutoSuggestion(Class<?> clazz)
   {
      manager._populateAutoSuggestion(clazz);
   }

   public static List<Object> getAutoSuggestions(String value, String attrName, Class<?> clazz, int limit)
   {
      return manager._getAutoSuggestions(value, attrName, clazz, limit);
   }


   private void _indexAutoSuggestions(List<AutoSuggestion> suggestions)
   {
      try
      {
         if (suggestions.size() > 0)
         {
            pm.insert(suggestions);
            totalIndexed += suggestions.size();
            double progress = (100.0d * totalObject / (totalHits == 0? 1: 0.0d + totalHits));
            AuditingUtil.audit("AutoSuggestions",
                               "Total suggestions indexed " + totalIndexed + " processed " + totalObject + " in " +
                               totalHits + "(" + progress + "%)");
         }
      }
      catch (IndexingException e)
      {
         e.printStackTrace();
      }
   }
   

   private List<IndexedDocument> next(QueryMetaData qmd, Class<?> clazz, int offset, int limit)
   {
      qmd.setPageSize(limit);
      qmd.setOffset(offset);
      try
      {
         SearchHits searchHits = pm.search(qmd, clazz);
         totalObject += limit;
         totalHits = searchHits.getHitsMetaData().getHits();
         return searchHits.getIndexedDocuments();
      }
      catch (SearchException se)
      {
         se.printStackTrace();
      }
      return Collections.emptyList();
   }

   private void _populateAutoSuggestion(Class<?> clazz)
   {
      QueryMetaData qmd = pm.getQmd("", clazz);
      qmd.setQueryString("*:*");
      qmd.enableFacets(false);

      int page = 1;
      int limit = 1000;

      List<IndexedDocument> docs = next(qmd, clazz, page, limit);

      while (docs.size() != 0)
      {
         List<AutoSuggestion> suggestions = new ArrayList<AutoSuggestion>();
         for (IndexedDocument doc: docs)
         {
            suggestions.addAll(_getAutoSuggestions(doc));
            if (suggestions.size() > batchSize)
            {
               _indexAutoSuggestions(suggestions);
               suggestions.clear();
            }
         }
         page++;
         if (suggestions.size() > 0)
         {
            _indexAutoSuggestions(suggestions);
         }
         docs = next(qmd, clazz, page, limit);
      }
   }

   private List<Object> _getAutoSuggestions(String value, String attrName, Class<?> clazz, int limit)
   {

      QueryMetaData qmd = null;

      qmd = pm.getQmd(value + "*", AutoSuggestion.class);
      qmd.enableFacets(false);
      qmd.addFilter("attrName", "string", attrName, "EQ");
      qmd.addFilter("objectName", "string", clazz.getName(), "EQ");

      qmd.setPageSize(limit);
      qmd.setOffset(1);

      try
      {
         SearchHits searchHits = pm.search(qmd, AutoSuggestion.class);
         List<Object> segguestedValues = new ArrayList<Object>();
         for (IndexedDocument doc: searchHits.getIndexedDocuments())
         {
            segguestedValues.add("" + doc.getAttrValue("value"));
         }
         return segguestedValues;
      }
      catch (SearchException se)
      {
         se.printStackTrace();
      }
      return Collections.emptyList();
   }

   private List<AutoSuggestion> _getAutoSuggestions(Document object)
   {
      List<AutoSuggestion> suggestions = new ArrayList<AutoSuggestion>();
      for (AttributeDefinition ad: object.getDocumentDef().getAttrDefs())
      {
         if (ad.isFacetAttr() && ad.getDataType().equals(AttributeDefinition.STRING))
         {
            String value = (String) object.getAttrValue(ad.getName());
            AutoSuggestion as =
               new AutoSuggestion(value, ad.getName(), object.getSearchableObject().getName(), value, object.getLanguage());
            if (cache.get(as.getId()) == null)
            {
               suggestions.add(as);
               cache.put(as.getId(), as);
            }
            else
            {
               cacheHits++;
            }
         }
      }
      return suggestions;
   }
   
   public static void queueForUpdates(Document document)
   {
      manager._indexAutoSuggestions(manager._getAutoSuggestions(document));
   }
}
