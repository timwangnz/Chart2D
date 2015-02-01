package org.sixstreams.search.crawl.crawler;

import java.util.Map;

import org.sixstreams.search.Crawler;
import org.sixstreams.search.LifeCycleListener;


/**
 * Threadable crawler interface
 */
public interface RunnableCrawler
   extends Runnable, Crawler
{
   public static final String LIFE_CYCLE_LISTENER_KEY = "org.sixstreams.search.lifecycle.listener";
   public static final String CRAWL_STOP_REQUEST = "org.sixstreams.search.job.request.stop";
   public static final String SEARCHABLE_OBJECT_KEY = "org.sixstreams.search.searchable.object";

   public final String USERNAME_KEY = "username";
   public final String PASSWORD_KEY = "password";
   public final String URL_KEY = "url";
   public final String CRAWLER_CLASS_KEY = "org.sixstreams.search.crawl.crawler.class";
   public final String CONTENT_TYPE_KEY = "contentType";

   boolean busy();

   void start(boolean withThread);

   boolean finished();

   void stop();

   boolean isStopping();

   public void setIncremental(boolean b);

   public void addLifeCycleListener(LifeCycleListener listener);

   public void setContextParam(String key, Object value);

   public void assignContextParams(Map<String, Object> params);
}
