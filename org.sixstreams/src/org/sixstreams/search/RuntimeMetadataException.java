package org.sixstreams.search;

public class RuntimeMetadataException
   extends RuntimeSearchException
{
   private static final long serialVersionUID = 1L;

   public RuntimeMetadataException(String msg)
   {
      super(msg);
   }

   public RuntimeMetadataException(Throwable throwable)
   {
      super(throwable);
   }

   public RuntimeMetadataException(String msg, Throwable cause)
   {
      super(msg, cause);
   }
}
