package org.sixstreams.search.meta;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;


/**
 * Primary Key is a mMap that holds primary key information for a document.
 *
 */
public class PrimaryKey
   implements Map
{

   private HashMap<Object, Object> fileds = new HashMap<Object, Object>();

   /**
    * Factory method to construct a primary key instance from a serialized
    * string. This is used in conjunction with toString
    * @param key string representation of a primary key.
    * @return the primary key.
    */
   public static PrimaryKey newInstance(String key)
   {
      PrimaryKey primaryKey = new PrimaryKey();
      String[] keyPairs = key.split(";");

      for (int i = 0; i < keyPairs.length; i++)
      {
         String[] keys = keyPairs[i].split(",");
         if (keys.length == 2)
         {
            primaryKey.put(keys[0], keys[1]);
         }
      }
      return primaryKey;
   }

   //serialize a primary key

   public String toString()
   {
      String pk = "";
      for (Iterator<Object> keys = fileds.keySet().iterator(); keys.hasNext(); )
      {
         String key = (String) keys.next();
         pk += key + "," + fileds.get(key);
         if (keys.hasNext())
         {
            pk += ";";
         }
      }
      return pk;
   }

   public Object put(Object key, Object value)
   {
      return fileds.put(key.toString(), value);
   }

   public Object get(Object key)
   {
      return fileds.get(key);
   }

   public Object remove(Object key)
   {
      return fileds.remove(key);
   }

   public Set keySet()
   {
      return fileds.keySet();
   }

   public Set entrySet()
   {
      return fileds.entrySet();
   }

   public void putAll(Map map)
   {
      this.fileds.putAll(map);
   }

   public Collection<Object> values()
   {
      return fileds.values();
   }

   public boolean containsValue(Object value)
   {
      return fileds.containsValue(value);
   }

   public boolean containsKey(Object key)
   {
      return fileds.containsKey(key);
   }

   public boolean isEmpty()
   {
      return fileds.isEmpty();
   }

   public void clear()
   {
      fileds.clear();
   }

   public int size()
   {
      return fileds.size();
   }
}
