package org.sixstreams.search.crawl.crawler;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.Crawlable;
import org.sixstreams.search.IndexableDocument;


/**
 * Represents a logic node that crawler can access to get
 *    list of end points
 *    content to be indexed
 */
public class CrawlableImpl
   implements Crawlable
{
   public static final String CONFIGFEED = "configFeed";
   public static final String CONTROLFEED = "controlFeed";
   public static final String DATAFEED = "dataFeed";
   public static final String FEED_URL = "http://sixstreams.org/";

   private String url;
   private List<String> urls = new ArrayList<String>();
   private Object content;
   private String contentType;
   private Map<String, Object> context = new HashMap<String, Object>();
   private int level;
   //reference to the cralwer
   private AbstractCrawler crawler;

   public CrawlableImpl(AbstractCrawler crawler, String url)
   {
      this.url = url;
      this.crawler = crawler;
   }

   public CrawlableImpl(AbstractCrawler crawler, String url, List<String> childUrls, Object content)
   {
      this(crawler, url);
      if (childUrls != null)
      {
         for (String childUrl: childUrls)
         {
            addUrl(childUrl);
         }
      }
      setIndexableContent(createIndexableDocument(url, content));
   }


   public void setLevel(int level)
   {
      this.level = level;
   }

   public int getLevel()
   {
      return level;
   }

   public void setContext(String key, Object value)
   {
      context.put(key, value);
   }

   public Object getContext(String key)
   {
      return context.get(key);
   }


   public Object getIndexableContent()
   {
      return content;
   }

   public void setIndexableContent(Object content)
   {
      this.content = content;
   }

   public void addUrl(String url)
   {
      urls.add(url);
   }

   public List<String> getUrls()
   {
      return urls;
   }

   public String getUrl()
   {
      return url;
   }

   public void setContentType(String mContentType)
   {
      this.contentType = mContentType;
   }

   public String getContentType()
   {
      return contentType;
   }
   //for extensions

   public IndexableDocument getDocument(String docId)
   {
      return null;
   }

   public List<Crawlable> getCrawlables()
   {
      return Collections.emptyList();
   }
   //to be overridden by the implementation

   private IndexableDocument createIndexableDocument(String url, Object content)
   {
      if (content instanceof IndexableDocument)
      {
         return (IndexableDocument) content;
      }

      if (content == null)
      {
         return null;
      }
      ContentMapper contentMapper = crawler.getContentMapper(url);
      if (contentMapper == null)
      {
         System.err.println("Failed to get content mapper for " + url);
         return null;
      }

      return contentMapper.createIndexableDocument(url, content);
   }
}
