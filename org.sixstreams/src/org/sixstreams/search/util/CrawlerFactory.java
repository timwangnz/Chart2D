package org.sixstreams.search.util;

import java.util.Hashtable;
import java.util.Map;

import org.sixstreams.search.crawl.crawler.AbstractCrawler;
import org.sixstreams.search.crawl.crawler.ContentMapper;
import org.sixstreams.search.crawl.crawler.GraphAnalyzer;
import org.sixstreams.search.meta.SearchableObject;

/**
 * Factory class to create crawler
 */
public class CrawlerFactory
{
   public final static String DEFAULT_MAP_KEY = "org.sixstreams.search.crawl.content.default";
   public final static String DEFAULT_ANALYZER_KEY = "org.sixstreams.search.crawl.analyzer.default";
   private static Map<String, String> crawlers = new Hashtable<String, String>();
   private static Map<String, String> mappers = new Hashtable<String, String>();
   private static Map<String, String> analyzers = new Hashtable<String, String>();
   static
   {
      crawlers.put("file/file", "org.sixstreams.search.crawl.file.FileCrawler");
      crawlers.put("jdbc/object", "org.sixstreams.search.crawl.db.DatabaseCrawler");
      crawlers.put("http/rss", "org.sixstreams.search.crawl.rss.RssCrawler");
      crawlers.put("http/html", "org.sixstreams.search.crawl.web.WebCrawler");
   }

   public static GraphAnalyzer getGraphAnalyzer(String url)
   {
      for (String keyString: analyzers.keySet())
      {
         if (url.startsWith(keyString))
         {
            return (GraphAnalyzer) ClassUtil.create(analyzers.get(keyString));
         }
      }
      return (GraphAnalyzer) ClassUtil.create(analyzers.get(DEFAULT_ANALYZER_KEY));
   }

   public static ContentMapper getContentMapper(String url)
   {
      //we need to use expression here
      for (String keyString: mappers.keySet())
      {
         if (url.startsWith(keyString))
         {
            return (ContentMapper) ClassUtil.create(mappers.get(keyString));
         }
      }
      return (ContentMapper) ClassUtil.create(mappers.get(DEFAULT_MAP_KEY));
   }

   public static void registerMapper(String objectName, String crawlerName)
   {
      mappers.put(objectName, crawlerName);
   }

   public static void registerGraphAnalyzer(String objectName, String crawlerName)
   {
      analyzers.put(objectName, crawlerName);
   }

   public static void registerCrawler(String objectName, String crawlerName)
   {
      crawlers.put(objectName, crawlerName);
   }

   public static AbstractCrawler getCrawler(String url)
   {
      if (url == null)
      {
         return null;
      }
      AbstractCrawler crawler = null;

      try
      {
         String crawlerClassname = crawlers.get(url);
         if (crawlerClassname == null)
         {
            crawlerClassname = url;
         }
         crawler = (AbstractCrawler) ClassUtil.create(crawlerClassname);
      }
      catch (Exception e)
      {
         e.printStackTrace();
         return null;
      }
      finally
      {
         if (crawler != null)
         {
            crawler.setIncremental(false);
         }
      }
      return crawler;
   }

   public static AbstractCrawler getCrawler(SearchableObject obj)
   {
      String crawlerClassname = crawlers.get(obj.getClass().getName());
      return getCrawler(crawlerClassname);
   }
}
