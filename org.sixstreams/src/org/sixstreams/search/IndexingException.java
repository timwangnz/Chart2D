package org.sixstreams.search;

/**
 * An exception thrown when a search engine fails to index a document.
 */
public class IndexingException
   extends Exception
{

   private static final long serialVersionUID = -1L;

   /**
    * Constructs an IndexingException from another exception.
    *
    * @param e causing exception.
    */
   public IndexingException(Exception e)
   {
      super(e);
   }

   /**
    * Constructs an IndexingException from a message.
    *
    * @param msg error message.
    */
   public IndexingException(String msg)
   {
      super(msg);
   }
}
