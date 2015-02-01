package org.sixstreams.social;

public class SocialRuntimeException
   extends RuntimeException
{
   public SocialRuntimeException(String msg, Throwable t)
   {
      super(msg, t);
   }
}
