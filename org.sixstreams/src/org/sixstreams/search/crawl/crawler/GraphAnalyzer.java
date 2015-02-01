package org.sixstreams.search.crawl.crawler;

import org.sixstreams.search.Crawler;


public interface GraphAnalyzer
{
   public boolean isChildCrawlable(CrawlableEndpoint endPoint, Object childObject);

   public Crawler getCrawler();

   public void setCrawler(Crawler crawler);
}
