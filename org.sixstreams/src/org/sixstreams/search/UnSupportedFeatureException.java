package org.sixstreams.search;

/**
 * An exception thrown when a search engine fails to index a document.
 */
public class UnSupportedFeatureException
   extends RuntimeException
{

   private static final long serialVersionUID = 1L;

   public UnSupportedFeatureException(String msg)
   {
      super(msg);
   }
}
