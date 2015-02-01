package org.sixstreams.app.marketIntel;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;

public class BeanPrinter
{
   public  static String toString(Object bean)
   {
      StringBuffer stringValue = new StringBuffer();
      try
      {
         Class<? extends Object> clazz = bean.getClass();
         BeanInfo beanInfo = Introspector.getBeanInfo(clazz);

         for (PropertyDescriptor pd: beanInfo.getPropertyDescriptors())
         {
            if (pd.getReadMethod() != null && pd.getWriteMethod() != null)
            {
               try
               {
                  stringValue.append(pd.getName()).append(":").append(pd.getReadMethod().invoke(bean, new Object[]{})).append("\n");
               }
               catch (Exception e)
               {
                  //does nothing
               }  
            }
         }
      }
      catch (IntrospectionException ie)
      {
         // TODO: Add catch code
         ie.printStackTrace();
      }
      return stringValue.toString();   
   }
}
