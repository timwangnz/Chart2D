package org.sixstreams.search.solr.query;


import java.lang.reflect.Type;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.sixstreams.Constants;
import org.sixstreams.rest.writers.JSONWriter;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.PrimaryKey;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.IndexedDocumentImpl;
import org.sixstreams.search.solr.SearchEngineImpl;
import org.sixstreams.search.util.ContextFactory;

import org.apache.solr.common.SolrDocument;


public class SolrIndexedDocumentImpl
   extends IndexedDocumentImpl
   implements Constants
{
   private String getStringValue(SolrDocument document, String attrName)
   {
      Object object = document.getFieldValue(attrName);
      if (object == null)
      {
         return "";
      }
      if (object instanceof Collection)
      {
         StringBuffer sb = new StringBuffer();
         for (Object obj: (Collection<?>) object)
         {
            sb.append(obj).append(" ");
         }
         return sb.toString().trim();
      }
      return object.toString();
   }

   public SolrIndexedDocumentImpl(SearchableObject searchableObject, SolrDocument document,
                                  Map<String, Map<String, List<String>>> highlights)
   {
      super(searchableObject);

      setTitle(getStringValue(document, TITLE));

      setContent(getStringValue(document, CONTENT));
      Float score = (Float) document.getFieldValue("score");

      setScore(score.intValue() * 100);

      String pk = getStringValue(document, PRIMARY_KEY);
      if (highlights != null)
      {
         Map<String, List<String>> dochighlights = highlights.get(pk);
         if (dochighlights != null)
         {
            Object snippets = dochighlights.get("content");
            if (snippets != null)
            {
               if (snippets instanceof List)
               {
                  List<?> snippetList = (List<?>) snippets;
                  StringBuffer snippet = new StringBuffer();
                  for (int i = 0; i < snippetList.size(); i++)
                  {
                     snippet.append("..." + snippetList.get(i) + "...");
                     if (snippet.length() > 200)
                     {
                        break;
                     }
                     snippet.append(" ");
                  }
                  setContent(snippet.toString());
               }
            }
         }
      }

      PrimaryKey primaryKey = PrimaryKey.newInstance(pk);
      setPrimaryKey(primaryKey);
      
      DocumentDefinition doc = searchableObject.getDocumentDef();
      for (String key: document.getFieldNames())
      {
         String attrName = SearchEngineImpl.getAttrName(key);
         AttributeDefinition fd = getAttrDefinition(doc, attrName);
         if (fd != null)
         {
            Object value = document.get(key);
            if (fd.isEncrypted())
            {
            	try
				{
					value = ContextFactory.getSearchContext().getCryptor().decrypt(value);
				}
				catch (Exception e)
				{
					sLogger.severe("Failed to decrypt a value for "+ attrName);;
					value = "";
				}
            }
            
            if (value instanceof String)
            {
               Type clazz = fd.getType();
               
               if (!clazz.equals(String.class) && !clazz.equals(StringBuffer.class))
               {
                  JSONWriter writer = new JSONWriter();
                  value = writer.toObject(value.toString(), clazz);
               }
            }
            setAttrValue(attrName, value);
         }
      }
   }

   private AttributeDefinition getAttrDefinition(DocumentDefinition doc, String fieldName)
   {
      for (AttributeDefinition fd: doc.getAttrDefs())
      {
         if (fd.getName().equals(fieldName))
         {
            return fd;
         }
      }
      return null;
   }
}
