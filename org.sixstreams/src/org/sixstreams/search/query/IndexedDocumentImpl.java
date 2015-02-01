package org.sixstreams.search.query;

import java.math.BigDecimal;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.List;
import java.util.logging.Level;

import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.res.DefaultBundle;


/**
 * Implemenation of IndexedDocument.
 */
public class IndexedDocumentImpl
   extends AbstractIndexedDocument
{

   private static final String DATE_FORMAT_GMT = "EEE, dd MMM yyyy HH:mm:ss z";

   private static final String DATE_TYPE = "DATE";
   private static final String NUBMER_TYPE = "NUMBER";
   private static final String TITLE = "title";
   private static final String DESC = "description";

   /**
    * Constructed from a list mAttributes. Should not be used for any purpose other
    * than search action. It needs to re-constrcut a document from a
    * serialization of attribute values.
    *
    * @param ctx the search context.
    * @param customAttrs attribute values hashed against name.
    */
   public IndexedDocumentImpl(SearchContext ctx, List<AttributeValue> customAttrs)
   {
      super(ctx.getSearchableObject());

      for (AttributeValue av: customAttrs)
      {
         super.setAttrValue(av.getName(), av.getValue());
      }
   }

   /**
    * Constructor of an empty document for a given searchable object.
    * @param obj     the searchable object for this document.
    */
   public IndexedDocumentImpl(SearchableObject obj)
   {
      super(obj);
   }

   /**
    * Returns field value by binding.
    * Special treatment is given to following key values
    * <ul>
    * <li>for title, ses title is returned</li>
    * <li>for mDescription, ses content is returned<li>
    * </ul>
    * @return field value.
    */
   public Object getAttrValue(String key)
   {
      //
      //this only occurs when we have an attribute named title
      //this is seeded SES attribute
      if (TITLE.equalsIgnoreCase(key))
      {
         return this.getTitle();
      }
      //
      //this only occurs when we have an attribute named description
      //this is seeded SES attribute
      //
      if (DESC.equalsIgnoreCase(key))
      {
         return this.mDescription;
      }
      return super.getAttrValue(key);
   }

   /**
    * Returns decription of the indexed document.
    * @return descritpion of this document.
    */
   public String getDescription()
   {
      return mDescription == null? content: mDescription;
   }

   /**
    * Sets description attribute.
    * @param description
    */
   protected void setDescription(String description)
   {
      mDescription = description;
   }


   /**
    * Sets attribute value. Data type conversion occur in this method.
    * @param attrName      the name of attribute.
    * @param strValue      the value of the attribute.
    */
   protected void setAttrValue(String attrName, String strValue)
   {
      AttributeDefinition fd = getSearchableObject().getDocumentDef().getAttributeDef(attrName);

      //
      //if no field definition, we simply ignore, this is a normal condition
      //
      if (fd == null)
      {
         super.setAttrValue(attrName, strValue);
         return;
      }

      super.setAttrValue(attrName, convertAttribute(fd, strValue));
   }

   /**
    * Converts string value to data object. If fails to convert, the string value
    * should be returned, and a warning message should be logged.
    *
    * Overrides this method if engine dependent conversion is needed.
    *
    * @param fieldDefinition     the attribute definition
    * @param strValue            the string value to be converted.
    * @return                    converted value object.
    */
   protected Object convertAttribute(AttributeDefinition fieldDefinition, String strValue)
   {
      Object value = strValue;
      if (strValue != null)
      {
         if (DATE_TYPE.equals(fieldDefinition.getDataType()))
         {
            try
            {
               value = new SimpleDateFormat(DATE_FORMAT_GMT).parse(strValue);
            }
            catch (ParseException e)
            {
               if (sLogger.isLoggable(Level.WARNING))
               {
                  sLogger.log(Level.WARNING, DefaultBundle.getResource(DefaultBundle.INDEXEDDOC_DATE_FORMAT_ERROR, new String[]
                           { strValue, fieldDefinition.getName(), getSearchableObject().getName() }), e);
               }
            }
         }

         if (NUBMER_TYPE.equals(fieldDefinition.getDataType()))
         {
            try
            {
               value = new BigDecimal(strValue);
            }
            catch (Exception e)
            {
               if (sLogger.isLoggable(Level.WARNING))
               {
                  sLogger.log(Level.WARNING, DefaultBundle.getResource(DefaultBundle.INDEXEDDOC_NUMBER_FORMAT_ERROR, new String[]
                           { strValue }), e);
               }
            }
         }
      }
      return value;
   }

   private String mDescription;


}
