package org.sixstreams.search;


import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.PrimaryKey;
import org.sixstreams.search.meta.SearchableObject;


/**
 * This class implements default methods required by Document. It should be extended
 * by search engine specific implementations to implement IndexableDocument and
 * IndexedDocument.
 *
 */
public class AbstractDocument
   implements Document
{
   protected static final String ERROR_URL = "http://org.sixstreams.com/error";
   protected static final String APPS_URL = "http://org.sixstreams.com/search/";

   /**
    * Constructor
    **/
   public AbstractDocument(SearchableObject searchableObject)
   {
      if (searchableObject == null)
      {
         throw new IllegalArgumentException("Searchable object must not be null");
      }

      if (searchableObject.getDocumentDef() == null)
      {
         throw new IllegalArgumentException("Searchable object has not initialized properly.");
      }

      this.searchableObject = searchableObject;
   }

   /**
    * Default Constrcutor
    */
   public AbstractDocument()
   {
   }

   /**
    * Get String representation of this document.
    * @return String value
    */
   public String toString()
   {
      return getTitle();
   }

   /**
    * @inheritDoc
    */
   public String getLanguage()
   {
      return mLanguage;
   }

   /**
    * @inheritDoc
    */
   public void setLanguage(String language)
   {
      this.mLanguage = language;
   }

   /**
    * Gets searchable object this document is based on.
    * @return searchable object.
    */
   public SearchableObject getSearchableObject()
   {
      return searchableObject;
   }

   /**
    * Gets document definition of this document.
    * @return abstract document definition
    */
   public DocumentDefinition getDocumentDef()
   {
      // child docs have docDef. parents get it from searchable object.
      if (docDef == null)
      {
         return searchableObject.getDocumentDef();
      }

      return docDef;
   }

   /**
    * Sets the document definition.
    * (called by addChildDoc)
    * @param docDef
    */
   public void setDocumentDef(DocumentDefinition docDef)
   {
      this.docDef = docDef;
   }

   /**
    * Sets primary key.
    * @param key new primary key.
    */
   public void setPrimaryKey(PrimaryKey key)
   {
      primaryKey = key;
   }

   /**
    * Gets primary key. It is a map of all fields that are marked
    * as primary key. Returns null if no field is marked as primary
    * key.
    * @return primary key for this document.
    */
   public PrimaryKey getPrimaryKey()
   {
      if (primaryKey != null)
      {
         return primaryKey;
      }

      boolean hasPrimaryKey = false;
      primaryKey = new PrimaryKey();

      DocumentDefinition doc = searchableObject.getDocumentDef();
      if (doc != null)
      {
         for (Iterator<AttributeDefinition> iter = doc.getAttrDefs().iterator(); iter.hasNext(); )
         {
            AttributeDefinition fd = iter.next();
            if (fd.isPrimaryKey())
            {
               primaryKey.put(fd.getName(), getAttrValue(fd.getName()));
               hasPrimaryKey = true;
            }
         }
      }

      if (!hasPrimaryKey)
      {
         return null;
      }
      return primaryKey;
   }

   //java doc from interface

   public Object getAttrValue(String attributeName)
   {
      if (attrMap.get(attributeName) == null)
      {
         return null;
      }

      return attrMap.get(attributeName).getValue();
   }

   //java doc from interface

   public void setAttrValue(String attrName, Object attrValue)
   {
      AttributeValue av = attrMap.get(attrName);
      if (av == null)
      {
         AttributeDefinition ad = getDocumentDef().getAttributeDef(attrName);
         if (ad != null)
         {
            av = new AttributeValue(this, ad, attrValue);
         }
      }
      if (av != null)
      {
         av.setValue(attrValue);
         attrMap.put(attrName, av);
      }
   }

   /**
    * Returns mContent of this document.
    * @return mContent.
    */
   public String getContent()
   {
      return content;
   }

   /**
    * Sets mContent of this document.
    * @param content new mContent.
    */
   public void setContent(String content)
   {
      this.content = content;
   }

   /**
    * Sets mContent type.
    * @param contentType new mContent type.
    */
   public void setContentType(String contentType)
   {
      this.contentType = contentType;
   }

   /**
    * Returns mContent type.
    * @return mContent type.
    */
   public String getContentType()
   {
      return this.contentType;
   }

   /**
    * @inheritDoc
    */
   public String getTitle()
   {
      return title;
   }

   /**
    * @inheritDoc
    */
   public void setTitle(String title)
   {
      this.title = title;
   }

   /**
    * @inheritDoc
    */
   public String getKeywords()
   {
      return keywords;
   }

   /**
    * @inheritDoc
    */
   public void setKeywords(String keywords)
   {
      this.keywords = keywords;
   }

   /**
    * @inheritDoc
    */
   public void addTags(List<String> tags)
   {
      this.tags.addAll(tags);
   }

   /**
    * @inheritDoc
    */
   public List<String> getTags()
   {
      return tags;
   }

   /**
    * @inheritDoc
    */
   public void clearTags()
   {
      tags.clear();
   }

   /**
    * @inheritDoc
    */
   public void addChildDoc(String name, Document doc)
   {
      List<Document> list = childDocsMap.get(name);

      if (list == null)
      {
         list = new ArrayList<Document>();
         childDocsMap.put(name, list);
      }

      if (!list.contains(doc))
      {
         list.add(doc);
      }
   }

   public List<String> getAttributeNames()
   {
      return new ArrayList<String>(attrMap.keySet());
   }

   public List<AttributeValue> getAttributeValues()
   {
      return new ArrayList<AttributeValue>(attrMap.values());
   }

   /**
    * @inheritDoc
    */
   public List<Document> getChildDocs(String name)
   {
      if (childDocsMap.get(name) == null)
      {
         return Collections.emptyList();
      }
      else
      {
         return childDocsMap.get(name);
      }
   }

   /**
    * Removes all child indexable documents (when no longer needed).
    */
   public void removeChildDocs()
   {
      childDocsMap.clear();
   }
   /* ----------------- Private members ------------------------------*/
   //name value pairs for custom attribute
   private Map<String, AttributeValue> attrMap = new HashMap<String, AttributeValue>();


   //conent to be indexed
   protected String content;
   private String contentType;
   private String title = "";
   private String keywords = "";

   //pk identify this docuement instance
   private PrimaryKey primaryKey;
   protected SearchableObject searchableObject;
   protected DocumentDefinition docDef;

   private HashMap<String, List<Document>> childDocsMap = new HashMap<String, List<Document>>();
   private String mLanguage;
   private ArrayList<String> tags = new ArrayList<String>();

}
