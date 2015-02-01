package org.sixstreams.search.data.java;

import java.beans.PropertyDescriptor;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;

import java.util.List;

import org.sixstreams.search.meta.AttributeDefImpl;


public class ObjectAttrDefinitionImpl
   extends AttributeDefImpl
{
   private transient PropertyDescriptor propertyDescriptor = null;

   public ObjectAttrDefinitionImpl(String name, PropertyDescriptor propertyDescriptor)
   {
      super(name, propertyDescriptor.getPropertyType().getName());
      this.propertyDescriptor = propertyDescriptor;
      if (propertyDescriptor.getPropertyType().equals(List.class))
      {
         this.setList(true);
         Type type = getType();
         if (type instanceof ParameterizedType) {
             ParameterizedType pt = (ParameterizedType) type;
             for (Type atp : pt.getActualTypeArguments())
             {
                 this.setListType(((Class<?>)atp).getName());
             }
         }
         
      }
   }

   
   public Type getType()
   {
      return propertyDescriptor.getReadMethod().getGenericReturnType();
   }

   public String toString()
   {
      return this.getName() + " " + this.getDataType() + " " + this.getDisplayName();
   }

   public PropertyDescriptor getPropertyDescriptor()
   {
      return propertyDescriptor;
   }
}
