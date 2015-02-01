package org.sixstreams.search;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.sixstreams.search.meta.AttributeDefinition;


public class AttributeValue
   implements Serializable
{
   private transient AttributeDefinition attributeDefinition;
   private transient Document document;
   private Object value;

   public AttributeValue(Document doc, AttributeDefinition fd, Object value)
   {
      attributeDefinition = fd;
      document = doc;
      setValue(value);
   }

   public Document getDocument()
   {
      return document;
   }

   public String getGroupName()
   {
      return attributeDefinition.getGroupName();
   }

   public String getDisplayName()
   {
      return attributeDefinition.getDisplayName();
   }

   public String getName()
   {
      return attributeDefinition.getName();
   }

   public AttributeDefinition getDefinition()
   {
      return attributeDefinition;
   }

   public String getDataType()
   {
      return attributeDefinition.getDataType();
   }

   public Object getValue()
   {
      if (attributeDefinition.isList() && value == null)
      {
         value = new ArrayList<Object>();
      }
      return value;
   }

   public void setValue(Object aValue)
   {
      if (value != null && value.equals(aValue))
      {
         return;
      }

      if (attributeDefinition.isList() && value == null)
      {
         value = new ArrayList<Object>();
      }

      if (attributeDefinition.isList())
      {
         List<Object> listValue = (List<Object>) value;
         if (aValue instanceof Collection)
         {
            listValue.clear();
            listValue.addAll((Collection) aValue);
         }
         else if (!listValue.contains(aValue))
         {
            listValue.add(aValue);
         }
      }
      else
      {
         value = aValue;
      }
   }

   public String toString()
   {
      return value != null? value.toString(): "";
   }

   public int getSequence()
   {
      return attributeDefinition.getSequence();
   }
}

