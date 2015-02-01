package org.sixstreams.search.data.java;

import java.math.BigDecimal;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class TypeMapper
{

   public static final String SES_STRING_TYPE = "string";
   public static final String SES_NUMBER_TYPE = "decimal";
   public static final String SES_DATETIME_TYPE = "dateTime";
   static final String DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
   static protected SimpleDateFormat sDateFormat = new SimpleDateFormat(DATE_FORMAT);

   public static final List<String> DATE_DATA_TYPES = Arrays.asList(new String[]
         { "DATE", "TIMESTAMP", "INTERVAL DAY TO SECOND", "INTERVAL YEAR TO MONTH", "TIMESTAMP WITH TIME ZONE",
           "TIMESTAMP WITH LOCAL TIME ZONE" });
   public static final List<String> NUMBER_DATA_TYPES = Arrays.asList(new String[]
         { "NUMBER", "FLOAT", "DEC", "DECIMAL", "INT", "INTEGER", "DOUBLE PRECISION", "NUMERIC", "SMALLINT", "REAL" });
   public static final List<String> STRING_DATA_TYPES = Arrays.asList(new String[]
         { "CHAR", "NCHAR", "VARCHAR2", "NVARCHAR2" });

   public static String toString(Object value)
   {
      if (value == null)
      {
         return "";
      }
      if (value instanceof Date)
      {
         return sDateFormat.format(value);
      }
      if (value instanceof Number)
      {
         return "" + value;
      }
      if (value instanceof String)
      {
         return value.toString();
      }
      return value.toString();
   }

   public static Object toObject(String type, String content)
   {
      if (content == null)
      {
         return null;
      }

      if ("string".equals(type))
         return content;

      if ("decimal".equals(type))
      {
         return new BigDecimal(content);
      }
      if ("dateTime".equals(type))
      {
         try
         {
            return sDateFormat.parse(content);
         }
         catch (ParseException e)
         {
            return null;
         }
      }
      return content;
   }

   public static String convert(String dataType)
   {
      String searchEngineDataType = SES_STRING_TYPE;
      if (STRING_DATA_TYPES.contains(dataType.toUpperCase()))
      {
         searchEngineDataType = SES_STRING_TYPE;
      }
      if (NUMBER_DATA_TYPES.contains(dataType.toUpperCase()))
      {
         searchEngineDataType = SES_NUMBER_TYPE;
      }
      if (DATE_DATA_TYPES.contains(dataType.toUpperCase()))
      {
         searchEngineDataType = SES_DATETIME_TYPE;
      }
      return searchEngineDataType;
   }

   private TypeMapper()
   {
      super();
   }

}
