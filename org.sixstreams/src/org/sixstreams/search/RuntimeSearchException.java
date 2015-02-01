package org.sixstreams.search;

/**
 * Exception thrown for all search related
 * exception. This exception is thrown for general search exceptions.
 */
public class RuntimeSearchException
   extends RuntimeException
{
   private static final long serialVersionUID = 1L;

   /**
    * Constructs an exception with a message.
    * @param msg exception related message.
    */
   public RuntimeSearchException(String msg)
   {
      super(msg);
   }

   /**
    * Constructs an exception from an exception.
    *
    * @param throwable the causing exception.
    **/
   public RuntimeSearchException(Throwable throwable)
   {
      super(throwable);
   }

   /**
    * Constructs an exception from an exception.
    *
    * @param msg exception related message.
    * @param throwable the causing exception.
    **/
   public RuntimeSearchException(String msg, Throwable cause)
   {
      super(msg, cause);
   }
}
