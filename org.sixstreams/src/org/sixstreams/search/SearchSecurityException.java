package org.sixstreams.search;

public class SearchSecurityException
   extends SearchException
{
   private static final long serialVersionUID = 1L;

   public SearchSecurityException(String msg)
   {
      super(msg);
   }

   public SearchSecurityException(Throwable throwable)
   {
      super(throwable);
   }

   public SearchSecurityException(String message, Throwable throwable)
   {
      super(message, throwable);
   }
}
