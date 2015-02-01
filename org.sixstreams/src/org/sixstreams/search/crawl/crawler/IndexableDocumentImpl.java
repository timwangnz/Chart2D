package org.sixstreams.search.crawl.crawler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.Constants;
import org.sixstreams.search.AbstractDocument;
import org.sixstreams.search.Attachment;
import org.sixstreams.search.Boostable;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.meta.SearchableObject;


public class IndexableDocumentImpl
   extends AbstractDocument
   implements IndexableDocument, Boostable
{
   private float boost;

   private Map<String, List<IndexableDocument>> childDocsMap = new HashMap<String, List<IndexableDocument>>();
   private List<Attachment> attachments = new ArrayList<Attachment>();
   private Map<String, List<String>> secureAttributes = new HashMap<String, List<String>>();
   private String actionType;
   private String accessUrl;

   public IndexableDocumentImpl(SearchableObject object)
   {
      super(object);
   }

   public IndexableDocumentImpl(String url)
   {
      super();
      accessUrl = url;
   }

   public void addAttachment(Attachment attachment)
   {
      attachments.add(attachment);
   }

   public List<Attachment> getAttachments()
   {
      return attachments;
   }

   public String getActionType()
   {
      return actionType;
   }

   public void setActionType(String actionType)
   {
      this.actionType = actionType;
   }

   public void setAttribueAcl(String fieldName, List<String> acl)
   {
      if (acl != null)
      {
         secureAttributes.put(fieldName, acl);
      }
      else
      {
         secureAttributes.remove(fieldName);
      }
   }

   /**
    * @inheritDoc
    */
   public List<String> getAcl()
   {
      return secureAttributes.get(Constants.ACL_KEY);
   }


   /**
    * @inheritDoc
    */
   public List<String> getAttributeAcl(String fieldName)
   {
      return secureAttributes.get(fieldName);
   }

   public String getContentType()
   {
      return "text/html";
   }

   public void setContentType(String contentType)
   {
      //
   }

   public void setBoost(float boost)
   {
      this.boost = boost;
   }

   public float getBoost()
   {
      return boost;
   }

   public Map<String, List<String>> getSecureAttributes()
   {
      return secureAttributes;
   }


   /**
    * Adds a child indexable document.
    */
   public void addChildDoc(String name, IndexableDocument doc)
   {
      if (childDocsMap.get(name) == null)
      {
         childDocsMap.put(name, new ArrayList<IndexableDocument>());
      }
      List<IndexableDocument> list = childDocsMap.get(name);
      list.add(doc);
   }


   public void overrideAccessURL(String accessURL)
   {
      accessUrl = accessURL;
   }

   public String getAccessURL()
   {
      return accessUrl;
   }

}
