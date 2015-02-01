package org.sixstreams.search.crawl.scheduler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import org.sixstreams.search.LifeCycleListener;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.crawl.crawler.AbstractCrawler;
import org.sixstreams.search.crawl.indexer.AbstractIndexer;
import org.sixstreams.search.crawl.indexer.IndexerManager;
import org.sixstreams.search.crawl.listener.CrawlListener;
import org.sixstreams.search.crawl.listener.IndexListener;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.CrawlerFactory;

/**
 * Primary runner class for executing a crawl job.
 */
public class ScheduleExecuter
   implements Runnable
{
   private static Logger sLogger = Logger.getLogger(ScheduleExecuter.class.getName());

   public static final String CRAWLER_CLASS_KEY = "org.sixstreams.search.object.crawler.class";
   private static final String DEFAULT_CRAWLER_TYPE = "jdbc/object";

   private static Map<Schedule, List<ScheduleExecuter>> sScheduleCrawlers =
      new HashMap<Schedule, List<ScheduleExecuter>>();

   private SearchableObject mSearchaleObject;

   protected Map<String, Object> mContext = new HashMap<String, Object>();
   private AbstractCrawler mCrawler;
   private IndexerManager mIndexManager;
   private AbstractIndexer mIndexer;
   private SearchContext mParentContext;
   private boolean mSync = false;
   private List<CrawlListener> mCrawlListeners = new ArrayList<CrawlListener>();
   private List<IndexListener> mIndexListeners = new ArrayList<IndexListener>();

   private Schedule mSchedule;

   private Thread myThread;

   public static void start(Schedule schedule)
   {
      for (SearchableObject object: schedule.getSearchableObjects())
      {
         ScheduleExecuter scheduleExecuter;
         scheduleExecuter = new ScheduleExecuter(object);

         List<ScheduleExecuter> executors = sScheduleCrawlers.get(schedule);
         if (executors == null)
         {
            executors = new ArrayList<ScheduleExecuter>();
            sScheduleCrawlers.put(schedule, executors);
         }
         scheduleExecuter.setSchedule(schedule);
         scheduleExecuter.addLifeCycleListener(schedule);
         executors.add(scheduleExecuter);
         scheduleExecuter.start();
      }
   }

   public static void stop(Schedule schedule)
   {
      List<ScheduleExecuter> list = sScheduleCrawlers.get(schedule);
      if (list != null && list.size() > 0)
      {
         for (ScheduleExecuter executor: list)
         {
            executor.stop();
         }
      }
   }

   public void start(boolean sync)
   {
      mSync = sync;

      if (mSync)
      {
         run();
      }
      else
      {
         start();
      }
   }

   public void start()
   {
      mParentContext = ContextFactory.getSearchContext();
      if (mSearchaleObject == null)
      {
         mSearchaleObject = mParentContext.getSearchableObject();
      }
      myThread = new Thread(this);
      myThread.start();
   }

   public void setSchedule(Schedule schedule)
   {
      mSchedule = schedule;
   }

   public void stop()
   {
      try
      {
         if (mIndexer != null)
         {
            mIndexer.close();
         }
      }
      catch (Exception exception)
      {
         exception.printStackTrace();
         //
      }
      if (mCrawler != null)
      {
         mCrawler.stop();
      }
      if (mSchedule != null)
      {
         mSchedule.setScheduleStatus(Schedule.READY);
      }
   }

   public final AbstractIndexer getIndexer()
   {
      return mIndexer;
   }

   public void setIndexer(AbstractIndexer indexer)
   {
      mIndexer = indexer;
   }

   protected List<CrawlListener> getCrawlListeners()
   {
      return mCrawlListeners;
   }

   protected List<IndexListener> getIndexListeners()
   {
      return mIndexListeners;
   }

   public void addLifeCycleListener(LifeCycleListener listener)
   {
      if (listener instanceof CrawlListener)
      {
         mCrawlListeners.add((CrawlListener) listener);
      }

      if (listener instanceof IndexListener)
      {
         mIndexListeners.add((IndexListener) listener);
      }
   }

   public ScheduleExecuter(String id, Map<String, Object> context)
   {
      mIndexManager = new IndexerManager();
      mContext.clear();
      mContext.putAll(context);
      mCrawler = CrawlerFactory.getCrawler(id);
   }

   public ScheduleExecuter(String id)
   {
      mCrawler = CrawlerFactory.getCrawler(id);
      mIndexManager = new IndexerManager();
   }

   public ScheduleExecuter(SearchableObject object)
   {
      mSearchaleObject = object;
      String crawlerClassName = object.getProperties().get(CRAWLER_CLASS_KEY);

      if (crawlerClassName == null)
      {
         crawlerClassName = MetaDataManager.getProperty(CRAWLER_CLASS_KEY, DEFAULT_CRAWLER_TYPE);
      }

      mIndexManager = new IndexerManager();
      mCrawler = CrawlerFactory.getCrawler(crawlerClassName);
      SearchContext ctx = ContextFactory.getSearchContext();
      ctx.setSearchableObject(object);

      SearchEngine se = MetaDataManager.getSearchEngine(object.getSearchEngineInstanceId());
      setIndexer((AbstractIndexer) se.getIndexer());
   }

   private void startIndexing()
   {
      if (mIndexer != null)
      {
         mIndexManager.addIndexer(mIndexer);
      }

      for (IndexListener listener: getIndexListeners())
      {
         mIndexManager.addIndexListener(listener);
      }
      mIndexManager.start(true);
   }

   public void run()
   {
      if (mCrawler == null)
      {
         return;
      }

      try
      {
         if (mParentContext != null)
         {
            SearchContext ctx = ContextFactory.getSearchContext();
            ctx.setUserName(mParentContext.getUserName());
            ctx.setSearchableObject(mSearchaleObject);
         }
         //sets up queues for this job
         if (mSchedule != null)
         {
            mIndexManager.setQueueId(mSchedule.getId());
            mCrawler.setQueueId(mSchedule.getId());
         }
         else if (mSearchaleObject != null)
         {
            mIndexManager.setQueueId(mSearchaleObject.getName());
            mCrawler.setQueueId(mSearchaleObject.getName());
         }
         else
         {
            mIndexManager.setQueueId(this.toString());
            mCrawler.setQueueId(this.toString());
         }

         for (CrawlListener listener: getCrawlListeners())
         {
            mCrawler.addLifeCycleListener(listener);
         }

         startIndexing();

         mCrawler.assignContextParams(mContext);
         mCrawler.start(true);

         Thread.sleep(50);
         while (!mCrawler.finished() || !mIndexManager.finished())
         {
            Thread.sleep(50);
            //
            //kill crawler and indexer if both has nothing to do
            //
            if (!mCrawler.busy() && !mIndexManager.busy())
            {
               mCrawler.stop();
               mIndexManager.stop();
            }
         }

         if (mSchedule != null)
         {
            mSchedule.setScheduleStatus(Schedule.READY);
            sLogger.fine("Finished the schedule " + mSchedule.getName());
         }

      }
      catch (Exception ie)
      {
         // TODO: Add catch code
         ie.printStackTrace();
      }
   }
}
