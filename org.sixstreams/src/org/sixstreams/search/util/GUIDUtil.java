package org.sixstreams.search.util;

import java.util.UUID;

public class GUIDUtil
{
   public static String getGUID(Object object)
   {
      return  UUID.randomUUID().toString();
   }
}
