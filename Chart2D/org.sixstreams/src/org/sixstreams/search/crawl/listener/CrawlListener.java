package org.sixstreams.search.crawl.listener;

import org.sixstreams.search.LifeCycleListener;

/**
 * Listener called once a document is retrieved from the source and prior to
 * being enqueued for process.
 */
public interface CrawlListener
   extends LifeCycleListener
{

}
