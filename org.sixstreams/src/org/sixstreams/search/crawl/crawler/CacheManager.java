package org.sixstreams.search.crawl.crawler;

import java.io.File;

import java.net.URI;
import java.net.URL;

import java.util.logging.Logger;

import org.sixstreams.search.meta.MetaDataManager;


public class CacheManager
{
	public static final String WEB_CACHE_LOCATION = "org.sixstreams.search.web.crawler.cache.location";

   protected static Logger sLogger = Logger.getLogger(CacheManager.class.getName());

   static boolean isCacheEnabled = false;
   private static String cachePath = MetaDataManager.getProperty(WEB_CACHE_LOCATION);

   private String getCacheFile(String url)
      throws Exception
   {
      File file = new File(cachePath);
      if (!file.exists())
      {
         file.mkdirs();
      }
      
      URL serverAddress = new URL(url);
      String protocol = serverAddress.getProtocol();
      String host = serverAddress.getHost();
      String query = serverAddress.getQuery();
      int port = serverAddress.getPort();
      String path = serverAddress.getPath();
      StringBuffer cacheFilePath = new StringBuffer(cachePath);
      cacheFilePath.append(host).append("/");
      if (port != -1)
      {
         cacheFilePath.append(port).append("/");
      }
      cacheFilePath.append(protocol).append("/");
      if (path != null)
      {
         cacheFilePath.append(path).append("/");
      }
/*
      Date date = new Date();
      cacheFilePath.append(date.getYear()).append("/");
      cacheFilePath.append(date.getMonth()).append("/");
      cacheFilePath.append(date.getDay()).append("/");
*/
      cacheFilePath.append(query);
      return cacheFilePath.toString();
   }

   public String save(String url)
   {
      try
      {
         URL serverAddress = new URL(url);
         File file = new File(getCacheFile(url));
         org.apache.commons.io.FileUtils.copyURLToFile(serverAddress, file);
         return getCacheFile(url);
      }
      catch (Throwable e)
      {
         e.printStackTrace();
      }
      return null;
   }

   public String cachedUrl(String url)
      throws Exception
   {
      if (isCacheEnabled)
      {
         File file = new File(getCacheFile(url));
         if (!file.exists())
         {
            save(url);
            sLogger.info("Saved to cache " + url  + " at " + file.getAbsolutePath());
         }
         else
         {
            sLogger.info("Hit cache " + url + " at " + file.getAbsolutePath());
         }
         file = new File(getCacheFile(url));

         if (file.exists())
         {
            URI uri = file.toURI();
            return uri.toURL().toString();
         }
         else
         {
            return url;
         }
      }
      return url;
   }
}
