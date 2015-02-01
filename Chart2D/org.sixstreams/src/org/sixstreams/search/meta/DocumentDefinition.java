package org.sixstreams.search.meta;

import java.io.Serializable;
import java.util.Collection;

/**
 * Decuement definition for a search engine. This is the base entity a search
 * engine works with.
 */
public interface DocumentDefinition extends Serializable
{
   /**
    * Returns field definitions for this document.
    * @return field definitions
    */
   Collection<AttributeDefinition> getAttrDefs();

   /**
    *Collection of attribute definitions for primary key
    * @return
    */
   Collection<AttributeDefinition> getKeyAttrDefs();

   AttributeDefinition getAttributeDef(String fieldName);

   AttributeDefinition getAttrDefByName(String fieldName);

   /**
    * Returns sub documents for this document.
    * @return sub documents.
    */
   Collection<DocumentDefinition> getChildDocumentDefs();

   /**
    * Adds a field to this document. Used internally by the
    * designer/loader to construct a new field to this document.
    * @param field
    */
   void addAttrDef(AttributeDefinition field);


   void setSearchableObject(SearchableObject searchableObject);

   String getName();
   void setAttrValueFor(Object obj, String attrName, Object attValue);

}
