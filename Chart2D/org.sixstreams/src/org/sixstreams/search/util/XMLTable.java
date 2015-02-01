package org.sixstreams.search.util;
/**
 * This class implements a map interface to parse an xml document. See
 * XMLUtil for more details
 */

import java.util.ArrayList;
import java.util.Collection;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class XMLTable implements Map
{
   private XMLTable mParent;
   private Map mTable = new Hashtable();

   public XMLTable(XMLTable parent)
   {
      super();
      this.mParent = parent;
   }

   public XMLTable getParent()
   {
      return mParent;
   }

   public void add(Object key, Object value)
   {
      Object existingObject = get(key);
      if (existingObject == null || key.equals(XMLUtil.TEXT_VALUE_KEY))
      {
         if (key.equals(XMLUtil.TEXT_VALUE_KEY))
         {
            if (value == null || value.toString().trim().length() == 0)
            {
               return;
            }
         }
         put(key, value);
      }
      else
      {
         List<Object> list = new ArrayList<Object>();
         if (existingObject instanceof List)
         {
            list = (List<Object>) existingObject;
         }
         else

         {
            list.add(existingObject);
         }
         list.add(value);
         put(key, list);
      }
   }

   //return list of xml tables if it is more than one element in the xml by the relative key, if not, returns a list with one object

   public List<?> getList(Object key)
   {
      Object list = get(key); //list
      if (list instanceof List)
      {
         return (List<?>) list;
      }
      else
      {
         List<Object> objects = new ArrayList<Object>();
         if (list != null)
         {
            objects.add(list);
         }
         return objects;
      }
   }

   //return a table if it is a unique element in the xml by the relative key, if not, returns null

   public XMLTable getTable(Object key)
   {
      Object obj = get(key);
      if (obj instanceof XMLTable)
      {
         return (XMLTable) obj;
      }
      else
      {
         XMLTable tbl = new XMLTable(this);
         return tbl;
      }
   }

   public Object get(Object key)
   {
      if (key instanceof String)
      {
         String strKey = key.toString();
         if (strKey.indexOf(".") == -1)
         {
            return mTable.get(key);
         }
         else
         {
            String[] keys = strKey.split("\\.");
            XMLTable table = this;
            for (String childKey: keys)
            {
               Object child = table.get(childKey);
               if (child == null)
               {
                  return null;
               }

               if (child instanceof XMLTable)
               {
                  table = (XMLTable) child;
               }
               else
               {
                  return child;
               }
            }
            return table;
         }
      }
      else
      {
         return mTable.get(key);
      }
   }

   public int size()
   {
      return mTable.size();
   }

   public boolean isEmpty()
   {
      return mTable.isEmpty();
   }

   public boolean containsKey(Object key)
   {
      return mTable.containsKey(key);
   }

   public boolean containsValue(Object value)
   {
      return mTable.containsValue(value);
   }

   public Object put(Object key, Object value)
   {
      return mTable.put(key, value);
   }

   public Object remove(Object key)
   {
      return mTable.remove(key);
   }

   public void putAll(Map m)
   {
      mTable.putAll(m);
   }

   public void clear()
   {
      mTable.clear();
   }

   public Set keySet()
   {
      return mTable.keySet();
   }

   public Collection values()
   {
      return mTable.values();
   }

   public Set entrySet()
   {
      return mTable.entrySet();
   }

   public String toString()
   {
      return mTable.toString();
   }
}
