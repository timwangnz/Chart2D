package org.sixstreams.search;

import java.util.List;

import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.PrimaryKey;
import org.sixstreams.search.meta.SearchableObject;


/**
 * An document represents an instance of a searchable object.
 */

public interface Document
{
   /**
    * Sets attribute value.
    * @param attributeName name of the attribute.
    * @param attributeValue new value for the attribute.
    */
   void setAttrValue(String attributeName, Object attributeValue);

   /**
    * Returns a field value from result for a given name.
    * @param name field name.
    * @return value of named field.
    */
   Object getAttrValue(String name);

   List<String> getAttributeNames();

   /**
    * Returns fields map hashed against attribute name.
    * @return mAttributes
    */
   List<AttributeValue> getAttributeValues();


   /**
    * Gets primaryKey of this document. Null if none.
    * @return primaryKey
    */
   PrimaryKey getPrimaryKey();

   /**
    * Sets primaryKey for this document;
    * @param pk
    */
   void setPrimaryKey(PrimaryKey pk);

   /**
    * Returns mContent type for this document.
    */
   String getContentType();

   /**
    * Sets contentType for this document.
    * @param contentType new conent.
    */
   void setContentType(String contentType);

   /**
    * Returns content assigned to this document.
    * @return content of this document.
    */
   String getContent();

   /**
    * Sets content for this document.
    * @param content new conent.
    */
   void setContent(String content);

   /**
    * Gets meta data definition for this document.
    * @return mSearchableObject that defines this document.
    */
   SearchableObject getSearchableObject();


   /**
    * Returns the language code for the document
    * @return language code for e.g. en_US.
    */
   String getLanguage();

   /**
    * Sets the language for the Document
    * @param language default language of this document.
    */
   void setLanguage(String language);

   /**
    * Returns title of this document.
    * @return title of this document.
    */
   String getTitle();

   /**
    * Sets title.
    * @param title new title.
    */
   void setTitle(String title);

   /**
    * Returns keywords of this document.
    * @return keywords of this document.
    */
   String getKeywords();

   /**
    * Sets keywords.
    * @param keywords new keywords.
    */
   void setKeywords(String keywords);

   /**
    * Adds a child indexable document.
    */
   void addChildDoc(String name, Document doc);

   /**
    * Gets a child indexable document by name.
    */
   List<Document> getChildDocs(String name);

   /**
    * Removes all child indexable documents (when no longer needed).
    */
   void removeChildDocs();

   /**
    * Gets document definition of this document.
    * @return abstract document definition
    */
   DocumentDefinition getDocumentDef();

   /**
    * Sets the document definition.
    * (called by addChildDoc)
    * @param docDef
    */
   void setDocumentDef(DocumentDefinition docDef);

   /**
    * Adds a list of tags to this document. Tags will be indexed with the
    * document when it is consumed by a search engine. Tags are indexed as
    * space delimited terms. Adding two of same tags will result just one
    * tag for the document.
    *
    * @param tags a list of tags.
    */
   void addTags(List<String> tags);

   /**
    * Returns a list of tags attached to this document.
    * @return a list of tags for this document.
    */
   List<String> getTags();

   /**
    * Clears tags added to this document.
    */
   void clearTags();
}
