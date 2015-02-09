package org.sixstreams.search.crawl.crawler;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.Constants;
import org.sixstreams.search.Crawlable;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.LifeCycleEvent;
import org.sixstreams.search.LifeCycleListener;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchSecurityException;
import org.sixstreams.search.Securable;
import org.sixstreams.search.crawl.content.ContentReader;
import org.sixstreams.search.crawl.content.ContentReaderProxy;
import org.sixstreams.search.crawl.listener.CrawlListener;
import org.sixstreams.search.crawl.listener.DocumentListener;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.CrawlerFactory;
import org.sixstreams.search.util.queue.Queue;
import org.sixstreams.search.util.queue.QueueManager;


/**
 * Abstract public crawler should be extended by any crawler for a specific type
 * of data source.
 */
abstract public class AbstractCrawler
   implements RunnableCrawler
{
   private static Logger sLogger = Logger.getLogger(AbstractCrawler.class.getName());

   private boolean incremental = false;
   private boolean stop;
   //add document to this queue once processed. Indexer will take from this queue
   private Queue documentQueue = QueueManager.getQueue(QueueManager.DOCUMENT_QUEUE_NAME);

   //add and remove from this queue for crawling
   private Queue urlQueue = QueueManager.getQueue(QueueManager.URL_QUEUE_NAME);

   private SearchContext parentContext;

   private final List<Thread> threads = new Vector<>();

   private final Map<String, Object> contextParams = new HashMap<>();
   private boolean busy = true;
   private SearchableObject searchableObject;
   private final List<CrawlListener> crawlListeners = new Vector<>();
   //called at all times to process data
   private final List<DocumentListener> documentListeners = new ArrayList<>();
   private String queueId;

   protected AbstractCrawler()
   {

   }

   protected abstract Crawlable retreive(CrawlableEndpoint endpoint)
      throws SearchException;

   public boolean busy()
   {
      return busy;
   }

   protected ContentMapper getContentMapper(String url)
   {
      ContentMapper contentMapper = CrawlerFactory.getContentMapper(url);
      contentMapper.setCrawler(this);
      return contentMapper;
   }

   protected GraphAnalyzer getGraphAnalyzer(Object object)
   {
      String url = "" + object;
      GraphAnalyzer graphAnalyzer = CrawlerFactory.getGraphAnalyzer(url);
      if (graphAnalyzer == null)
      {
         ContentMapper contentMapper = getContentMapper(url);
         if (contentMapper != null)
         {
            return contentMapper.getGraphAnalyzer(url);
         }
      }
      graphAnalyzer.setCrawler(this);
      return graphAnalyzer;
   }

   protected boolean isObjectCrawlable(CrawlableEndpoint endpoint, Object object)
   {
      GraphAnalyzer graphAnalyzer = getGraphAnalyzer(object);
      return graphAnalyzer != null && graphAnalyzer.isChildCrawlable(endpoint, object);
   }

   protected void audit(String key, Object value)
   {
      SearchContext searchContext = ContextFactory.getSearchContext();
      LifeCycleEvent auditEvent =
         new LifeCycleEvent(LifeCycleEvent.AUDITING, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, searchContext.getSearchableObject());
      auditEvent.put(key, value);
      raiseEvent(auditEvent);
   }

   public void assignContextParams(Map<String, Object> params)
   {
      contextParams.clear();
      contextParams.putAll(params);
   }

   public void setContextParam(String key, Object value)
   {
      contextParams.put(key, value);
   }

   public Object getContextParam(String key)
   {
      return contextParams.get(key);
   }

   //
   //get starting url for this crawl
   //

   protected abstract String getStartingUrl();

   //start this crawler at top url

   public final void startRun()
   {
      try
      {
         String url = getStartingUrl();
         raiseEvent(new LifeCycleEvent(LifeCycleEvent.START, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, url));
         CrawlableImpl crawlable = (CrawlableImpl) retreive(new CrawlableEndpoint(url, 0));
         queue(crawlable);
      }
      catch (SearchException e)
      {
         e.printStackTrace();
         handleException(e);
      }
   }

   //this method might be run in a child thread

   public final void run()
   {

      SearchContext ctx = ContextFactory.getSearchContext();

      if (ctx != parentContext)
      {
         //TODO populate child context if it runs in a separate thread
         ctx.setUserName(parentContext.getUserName());
         ctx.setSearchableObject(parentContext.getSearchableObject());
      }

      CrawlableImpl crawlable;
      while (!isStopRequested())
      {
         try
         {
            CrawlableEndpoint crawlablePoint = getNextQueuedEndPoint();
            if (crawlablePoint != null)
            {
               crawlable = (CrawlableImpl) retreive(crawlablePoint);

               if (crawlable != null)
               {
                  crawlable.setLevel(crawlablePoint.getLevel());
                  queue(crawlable);
               }
            }
            busy = !urlQueue.isEmpty();
         }
         catch (Throwable t)
         {
            handleException(t);
         }
      }
      busy = false;
   }

   public final void start(boolean withThread)
   {
      startRun();
      parentContext = ContextFactory.getSearchContext();

      if (withThread)
      {
         Thread thread = new Thread(this);
         threads.add(thread);
         thread.start();
      }
      else
      {
         run();
      }
   }

   private void processDocument(IndexableDocument indexableDocument)
      throws SearchSecurityException
   {
      SearchableObject so = indexableDocument.getSearchableObject();

      if (so == null)
      {
         return;
      }

      Object securityPlugin = null;

      securityPlugin = so.getSearchPlugin();
      if (securityPlugin instanceof Securable)
      {
         Securable securable = (Securable) securityPlugin;
         if (securable.isAclEnabled())
         {
            indexableDocument.setAttrValue(Constants.ACL_KEY, securable.getAcl(indexableDocument));
         }
      }

   }

   //called by the sub class to process document

   protected void processDocuments(List<IndexableDocument> documents)
   {
      for (IndexableDocument doc: documents)
      {
         try
         {
            processDocument(doc);
         }
         catch (SearchSecurityException sse)
         {
            sse.printStackTrace();
            //TODO we should remove this doc from the list
         }
      }
   }

   public boolean finished()
   {
      return this.stop;
   }

   public final void stop()
   {
      this.stop = true;
   }

   public final boolean isStopping()
   {
      return stop;
   }

   public final boolean isIncremental()
   {
      return this.incremental;
   }

   //protected

   protected void handleException(Throwable t)
   {
      if (t == null || t instanceof NullPointerException)
      {
         t = new RuntimeException("Null pointer exception", t);
      }

      raiseEvent(new LifeCycleEvent(LifeCycleEvent.ERROR, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, t));
   }

   //private methods

   private CrawlableEndpoint getNextQueuedEndPoint()
      throws SearchException
   {
      if (urlQueue.isEmpty())
      {
         return null;
      }
      CrawlableEndpoint endpoint = (CrawlableEndpoint) urlQueue.dequeue();
      audit("Queue Size", urlQueue.getSize());
      return endpoint;
   }

   private boolean isStopRequested()
   {
      Object stopRequest = ContextFactory.getSearchContext().getAttribute(CRAWL_STOP_REQUEST);
      return stop || (stopRequest != null && ((Boolean) stopRequest).booleanValue());
   }
   //update url queue

   private void queue(CrawlableImpl doc)
      throws SearchException
   {
      if (doc == null)
      {
         return; //do nothing, perhaps log
      }

      raiseEvent(new LifeCycleEvent(LifeCycleEvent.PRE_PROCESS, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, doc));
      handleCrawlable(doc);
      raiseEvent(new LifeCycleEvent(LifeCycleEvent.POST_PROCESS, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, doc));

      for (String url: doc.getUrls())
      {
         urlQueue.enqueue(url, new CrawlableEndpoint(url, doc.getLevel() + 1));
      }
   }
   //crawl

   private void handleCrawlable(CrawlableImpl crawlable)
   {
      Object obj = crawlable.getIndexableContent();

      if (obj instanceof Collection)
      {
         Collection<?> results = (Collection<?>) obj;
         for (Object result: results)
         {
            if (result instanceof IndexableDocument)
            {
               onQueueDoc((IndexableDocument) result);
            }
            else if (result instanceof CrawlableImpl)
            {
               handleCrawlable((CrawlableImpl) result);
            }
            else
            {
               //ContentReaderProxy reader = new
               ContentReader reader = new ContentReaderProxy(crawlable.getContentType());
               IndexableDocument doc = reader.process(crawlable, result);
               if (doc != null)
               {
                  onQueueDoc(doc);
               }
            }
         }
      }
      else if (obj instanceof IndexableDocument)
      {
         onQueueDoc((IndexableDocument) obj);
      }

      else if (obj != null)
      {
         ContentReader reader = new ContentReaderProxy(crawlable.getContentType());
         IndexableDocument doc = reader.process(crawlable, obj);
         if (doc != null)
         {
            onQueueDoc(doc);
         }
      }
   }

   private void onQueueDoc(IndexableDocument doc)
   {
      raiseEvent(new LifeCycleEvent(LifeCycleEvent.POST_PROCESS, org.sixstreams.search.LifeCycleEvent.Phase.CRAWL, doc));
      documentQueue.enqueue(doc.getPrimaryKey().toString(), doc);
   }

   public final void setIncremental(boolean incremental)
   {
      this.incremental = incremental;
   }

   public void setUrlQueue(Queue urlQueue)
   {
      this.urlQueue = urlQueue;
   }

   public void addLifeCycleListener(LifeCycleListener listener)
   {
      if (listener instanceof CrawlListener)
      {
         crawlListeners.add((CrawlListener) listener);
      }
      else if (listener instanceof DocumentListener)
      {
         documentListeners.add((DocumentListener) listener);
      }
   }

   public final void raiseEvent(LifeCycleEvent crawlStatus)
   {
      if (crawlStatus.getPhase() == org.sixstreams.search.LifeCycleEvent.Phase.CRAWL)
      {
         for (LifeCycleListener listener: crawlListeners)
         {
            listener.onLifeCycleEvent(crawlStatus);
         }
      }
      else if (crawlStatus.getPhase() == org.sixstreams.search.LifeCycleEvent.Phase.PROCESS)
      {
         for (LifeCycleListener listener: documentListeners)
         {
            listener.onLifeCycleEvent(crawlStatus);
         }
      }

      if (!crawlStatus.isErrorHandled() && LifeCycleEvent.ERROR.equals(crawlStatus.getEventType()))
      {
         if (crawlStatus.getObject() instanceof Throwable)
         {
            ((Throwable) crawlStatus.getObject()).printStackTrace();
         }

         sLogger.log(Level.SEVERE, "" + crawlStatus.getPhase(), crawlStatus.getObject());
      }
   }

   public List<CrawlListener> getCrawlListeners()
   {
      return crawlListeners;
   }

   protected void assign(AbstractCrawler crawler)
   {
      for (CrawlListener listener: crawler.getCrawlListeners())
      {
         addLifeCycleListener(listener);
      }

      for (DocumentListener listener: crawler.documentListeners)
      {
         addLifeCycleListener(listener);
      }
   }

   public void setSearchableObject(SearchableObject searchableObject)
   {
      this.searchableObject = searchableObject;
   }

   public SearchableObject getSearchableObject()
   {
      return searchableObject;
   }

   public void setQueueId(String queueId)
   {
      this.queueId = queueId;
      documentQueue = QueueManager.getQueue(QueueManager.DOCUMENT_QUEUE_NAME + "." + queueId);
      urlQueue = QueueManager.getQueue(QueueManager.URL_QUEUE_NAME + "." + queueId);
   }

   public String getQueueId()
   {
      return queueId;
   }
}

