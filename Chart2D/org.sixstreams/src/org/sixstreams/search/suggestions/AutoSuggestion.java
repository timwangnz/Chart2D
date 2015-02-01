package org.sixstreams.search.suggestions;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;

public class AutoSuggestion
{
   @SearchableAttribute(isKey = true, isIndexed = false)
   private String id;
   @SearchableAttribute(isIndexed = true)
   private String value;

   private String code;
   
   private String lang;
  
   private String attrName;
   
   private String objectName;

   public AutoSuggestion(String value, String attrName, String objectName, String code, String lang)
   {
      this.id = code + attrName + objectName + lang;
      this.value = value;
      this.attrName = attrName;
      this.objectName = objectName;
      this.lang = lang;
      this.code = code;
   }

   public void setValue(String value)
   {
      this.value = value;
   }

   public String getValue()
   {
      return value;
   }

   public void setAttrName(String attrName)
   {
      this.attrName = attrName;
   }

   public String getAttrName()
   {
      return attrName;
   }

   public void setId(String id)
   {
      this.id = id;
   }

   public String getId()
   {
      return id;
   }

   public void setObjectName(String objectName)
   {
      this.objectName = objectName;
   }

   public String getObjectName()
   {
      return objectName;
   }

   public void setCode(String code)
   {
      this.code = code;
   }

   public String getCode()
   {
      return code;
   }

   public void setLang(String lang)
   {
      this.lang = lang;
   }

   public String getLang()
   {
      return lang;
   }
}
