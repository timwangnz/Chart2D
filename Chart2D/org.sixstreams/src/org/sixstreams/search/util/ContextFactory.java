package org.sixstreams.search.util;

import org.sixstreams.search.RuntimeSearchException;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.impl.SearchContextImpl;
import org.sixstreams.search.meta.MetaDataManager;

/**
 * Factory class for context
 */
public final class ContextFactory
{
   public static final String CONTEXT_CLASS_PROP = "org.sixstreams.search.context.class";

   private ContextFactory()
   {

   }

   private static SearchContext getThreadLocalContext()
   {
      //what if ctx is not the same type as the class name
      SearchContext ctx = (SearchContext) mContext.get();
      if (ctx != null)
      {
         return ctx;
      }

      try
      {
         ctx =
               (SearchContext) ClassUtil.create(MetaDataManager.getProperty(CONTEXT_CLASS_PROP, SearchContextImpl.class.getName()));
      }
      catch (Exception e)
      {
         throw new RuntimeSearchException(e);
      }

      mContext.set(ctx);
      return ctx;
   }

   //thread local that holds context local to this thread

   private static ThreadLocal<SearchContext> mContext = new ThreadLocal<SearchContext>();

   /**
    * Return a thread local search cotnext. Each thread shares one search context.
    * @return a searchContext
    */
   public static SearchContext getSearchContext()
   {
      return getThreadLocalContext();
   }

   /**
    * Remove the thread local for cleanup
    */
   public static void remove()
   {
      mContext.remove();
   }
}
