package org.sixstreams.search;

import java.io.Writer;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import org.apache.commons.lang.WordUtils;

import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;


public abstract class AbstractDefaultContext
   implements SearchContext
{
   protected static Logger sLogger = Logger.getLogger(AbstractDefaultContext.class.getName());

   /**
    * Default Constrcutor.
    */
   public AbstractDefaultContext()
   {

   }

   /**
    * Sets a named attribute value. This will override the existing
    * value of the same key.
    */
   public void setAttribute(Object key, Object value)
   {
      map.put(key, value);
   }

   /**
    * Gets value of a named attribute.
    * @return attribute value.
    */
   public Object getAttribute(Object key)
   {
      return map.get(key);
   }
   //implementation

   public void setWriter(Writer writer)
   {
      this.writer = writer;
   }

   /**
    * Returns the writer associated with this context.
    */
   public Writer getWriter()
   {
      return writer;

   }

   /**
    * Returns application context assigned to this context.
    */
   public Object getExternalContext()
   {
      return externalContext;
   }

   /**
    * Sets application context to this context.
    */
   public void setExternalContext(Object ctx)
   {
      externalContext = ctx;
   }

   /**
    * Gets searchable object this context is created for.
    * @return SearchableObject.
    */
   public SearchableObject getSearchableObject()
   {
      return searchableObject;
   }

   /**
    * Binds this context to a searchable object. For each context, only
    * one searchable object can be associated at any time.
    */
   public void setSearchableObject(SearchableObject searchableObject)
   {
      this.searchableObject = searchableObject;
   }

   public void setEngineInstanceId(long engineInstanceId)
   {
      this.engineInstanceId = engineInstanceId;
   }

   public long getEngineInstanceId()
   {
      return engineInstanceId;
   }


   /**
    * Performs resource clean up.
    */
   public void release()
   {
      ContextFactory.remove();
   }

   /**
    * @inheritDoc
    */
   public Map<Object, Object> getAttributes()
   {
      return map;
   }


   /**
    * @inheritDoc
    */
   public String getResourceString(Object object, String key)
   {
      return splitCamelCase(WordUtils.capitalize(key));
   }

   public static String splitCamelCase(String s)
   {
      return s.replaceAll(String.format("%s|%s|%s", "(?<=[A-Z])(?=[A-Z][a-z])", "(?<=[^A-Z])(?=[A-Z])",
                                        "(?<=[A-Za-z])(?=[^A-Za-z])"), " ");
   }

   private HashMap<Object, Object> map = new HashMap<Object, Object>();
   private SearchableObject searchableObject;
   private long engineInstanceId = -1;
   private Object externalContext;
   private Writer writer;
}
