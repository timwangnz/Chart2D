package org.sixstreams.metadata;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.IndexingException;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.DataCommon;
import org.sixstreams.search.data.PersistenceManager;


public class MetaDataObject
   extends DataCommon
{
   private String objectType;
   private String key;
   private String dataType;
   private String value;
   private String version;

   static DecimalFormat numberFormat = new DecimalFormat("#,###");
   static DateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
   
   private static String toString(Object object)
   {
      if(object == null)
      {
         return "";
      }
      if (object instanceof String)
      {
         return object.toString();
      }
      if (object instanceof Date)
      {
         return dateFormat.format((Date) object);
      }
      
      if (object instanceof Long)
      {
         return numberFormat.format((Long) object);
      }
      if (object instanceof Float)
      {
         return numberFormat.format((Float) object);
      }
      return object.toString();
   }
   
   private static Object toObject(MetaDataObject object)
   {
      if(object == null)
      {
         return "";
      }
      try
      {
         if (object.getDataType().equals(String.class.getName()))
         {
            return object.getValue();
         }
         if (object.getDataType().equals(Date.class.getName()))
         {
            return dateFormat.parse(object.getValue());
         }
         if (object.getDataType().equals(Long.class.getName()))
         {
            return numberFormat.parse(object.getValue());
         }

         if (object.getDataType().equals(Float.class.getName()))
         {
            return numberFormat.parse(object.getValue());
         }

      }
      catch (ParseException pe)
      {
         // TODO: Add catch code
         pe.printStackTrace();
      }
      return object.getValue();
   }
   
   public static void putValue(String objectType, String objectKey, Object objectValue)
      throws SearchException, IndexingException
   {
      if (objectValue == null)
      {
         return;
      }
      PersistenceManager pm = new PersistenceManager();
      
      MetaDataObject meta = new MetaDataObject();
      meta.setId(objectType + ":" + objectKey);
      meta.setObjectType(objectType);
      meta.setDataType(objectValue.getClass().getName());
      meta.setKey(objectKey);
      meta.setValue(toString(objectValue));
      pm.insert(meta);
   }
   
   public static Object getValue(String objectType, String key)
      throws SearchException
   {
      PersistenceManager pm = new PersistenceManager();
      Map<String, Object> filters = new HashMap<String, Object>();
      filters.put("objectType", objectType);
      filters.put("key", key);
      List<?> list = pm.query(filters, MetaDataObject.class);
      if (list.size() == 0)
      {
         return null;
      }
      else
      {
         return toObject((MetaDataObject) list.get(0));
      }
   }

   public void setObjectType(String objectType)
   {
      this.objectType = objectType;
   }

   public String getObjectType()
   {
      return objectType;
   }

   public void setDataType(String dataType)
   {
      this.dataType = dataType;
   }

   public String getDataType()
   {
      return dataType;
   }

   public void setValue(String value)
   {
      this.value = value;
   }

   public String getValue()
   {
      return value;
   }

   public void setKey(String key)
   {
      this.key = key;
   }

   public String getKey()
   {
      return key;
   }

   public void setVersion(String version)
   {
      this.version = version;
   }

   public String getVersion()
   {
      return version;
   }
}
