package org.sixstreams.search.crawl.crawler;

@SuppressWarnings("serial")
public class CrawlException
   extends Exception
{
   public CrawlException(String msg, Throwable t)
   {
      super(msg, t);
   }
}
