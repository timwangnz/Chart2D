package org.sixstreams.search.crawl.web;

import org.sixstreams.search.LifeCycleEvent;
import org.sixstreams.search.crawl.crawler.CrawlableImpl;
import org.sixstreams.search.crawl.listener.CrawlListener;

public class CrawlListenerImpl
   implements CrawlListener
{
   public void onLifeCycleEvent(LifeCycleEvent event)
   {
      Object source = event.getObject();
      if (source instanceof CrawlableImpl && event.getEventType().equals(LifeCycleEvent.POST_PROCESS))
      {
         System.err.println("Crawled " + ((CrawlableImpl) event.getObject()).getUrl());
         return;
      }
   }
}
