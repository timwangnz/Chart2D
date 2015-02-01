package org.sixstreams.search.util;


public class PrimaryKeyUtil
{
   private static long RANDOM_START = System.currentTimeMillis();

   public static String getGUID()
   {
      return "" + RANDOM_START++;
   }

   public static long generateKey(Object fd)
   {
      return RANDOM_START++;
   }
}
