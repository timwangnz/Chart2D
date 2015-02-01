package org.sixstreams.search.crawl.content;

import java.io.IOException;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.crawl.crawler.CrawlableImpl;

public abstract class AbstractReader
   implements ContentReader
{
   protected String contentType;

   public void setContentType(String contentType)
   {
      this.contentType = contentType;
   }
   //to be overridden

   public IndexableDocument process(CrawlableImpl crawlable, Object content)
   {
      return null;
   }

   public void close()
      throws IOException
   {
   }
}
