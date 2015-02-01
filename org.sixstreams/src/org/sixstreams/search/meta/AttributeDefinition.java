package org.sixstreams.search.meta;

import java.io.Serializable;

import java.lang.reflect.Type;


/**
 * Attribute definition interface.
 */
public interface AttributeDefinition extends Serializable
{
   String STRING = "java.lang.String";
   /**
    * Returns the name of this definition.
    * @return name of the field.
    */
   String getName();

   /**
    * Returns display name of this field. It should be normally human
    * readable form, and i18nized. The locale of the search context will be used.
    * @return name of the field.
    */
   String getDisplayName();

   /**
    * Whether this is field is a secure field. If it is, its value
    * will be used for security filtering.
    * @return true if test positive.
    */
   boolean isSecure();

   /**
    * Whether this field is stored.
    * @return true if it is stored.
    */
   boolean isStored();

   /**
    * Whether value should be encrpted when stored
    * @return true if it should be encrypted
    */
   boolean isEncrypted();

   /**
    * Whether this field is stored.
    * @return true if it is stored.
    */
   boolean isIndexed();

   /**
    * Tests whether this field is a facet stored field.
    * @return true if it is a facet stored.
    */
   boolean isFacetAttr();

   /**
    * Returns a boost value for this field. Value 1 means neutrual. A larger value
    * indicates this field weighs more than ones that has a small value. Default
    * value is 1.
    * @return boost value for this field.
    */
   float getBoost();

   /**
    * Whether this field is part of primary key
    */
   boolean isPrimaryKey();

   /**
    * Returns data type of this field.
    * @return data type.
    */
   String getDataType();

   /**
    * Returns type of this field.
    * @return data type.
    */
   Type getType();

   /**
    * whether this field denotes the language of the document
    */
   boolean isLanguageAttr();

   /**
    * Returns sequence if this field should be displayed by the UI. This is an
    * advisory info for UI developers.
    *
    * @return a positive number indicating the order of this field
    */
   int getSequence();

   /**
    * Returns true if this attribute is sortable
    * @return whether this attribute is sortable
    */
   boolean isSortable();

   /**
    * Returns true if this attribute is displayable (UIHint)
    * @return displayable
    */
   boolean isDisplayable();

   /**
    * Returns true if this attribute is editable
    * @return editable
    */
   boolean isEditable();

   /**
    * Returns true if this attribute is required UIHint
    * @return required
    */
   boolean isRequired();

   /**
    * Flag if the attribute is a list.
    * @return isList
    */
   boolean isList();
   
   /**
    * if this is a list, returns class name of the list. Not used when isList returns false;
    * @return
    */
   String getListType();
   /**
    * Retruns group name this attribute belongs to. UIHint
    * @return group name.
    */
   String getGroupName();

   /**
    * Sets owner document definition. Internal use only

    */
   void setDocumentDef(DocumentDefinition docDef);

   /**
    * Returns the owner document definition of this attribute.
    * @return owner document definition
    */
   DocumentDefinition getDocumentDef();

   /**
    * Returns class name for data convertion for this attribute
    * @return data converter
    */
   String getConvertor();

   /**
    * Type of this attribute, e.g. email, phone, etc.
    * @return attribute type
    */
   String getReadableType();

   /**
    * Returns class name for aggregation function for
    * this attribute. This is used to aggregate the
    * value for display
    * @return aggregation function
    */
   String getAggregateFunction();

   /**
    * Returns definition of list of value for this attribute
    * @return LOV definition
    */
   String getLovDef();
   /**
    * Return name of parent class name if exist. 
    * @return class name of its parent object.
    */
   String getForeignKey();
}
