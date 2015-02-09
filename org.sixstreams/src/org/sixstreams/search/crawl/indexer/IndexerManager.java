package org.sixstreams.search.crawl.indexer;


import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.LifeCycleEvent;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.crawl.listener.DocumentListener;
import org.sixstreams.search.crawl.listener.IndexListener;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.queue.Queue;
import org.sixstreams.search.util.queue.QueueManager;

/**
 * Indexing Job Manager. Internal class
 */
public class IndexerManager
   implements Runnable
{
   private static final Logger sLogger = Logger.getLogger(IndexerManager.class.getName());

   private final List<IndexListener> mListeners = new ArrayList<>();

   private final List<AbstractIndexer> mIndexers = new ArrayList<>();
   private final int mSleepInterval = 50;
   private SearchContext mParentContext;
   private Queue mDocumentQueue = QueueManager.getQueue(QueueManager.DOCUMENT_QUEUE_NAME);
   private boolean mStop = false;
   private boolean mBusy = true;

   private String mQueueId;

   public boolean busy()
   {
      return mBusy;
   }

   public void addIndexer(AbstractIndexer listener)
   {
      mIndexers.add(listener);
   }

   public void addIndexListener(IndexListener listener)
   {
      mListeners.add(listener);
   }

   public void start(boolean withThread)
   {
      mParentContext = ContextFactory.getSearchContext();
      if (withThread)
      {
         Thread thread = new Thread(this);
         thread.start();
      }
      else
      {
         run();
      }
   }
   

   public AbstractIndexer getIndexer()
   {
      for (AbstractIndexer indexer: mIndexers)
      {

         if (indexer != null && !indexer.isBusy())
         {
            return indexer;
         }
      }
      return null;
   }

   private void close()
      throws IndexingException
   {
       //SearchContext ctx =
       mIndexers.stream().forEach((indexer) -> {
           indexer.close();
       });
   }

   private void raiseEvent(LifeCycleEvent event)
   {
       mListeners.stream().forEach((listener) -> {
           listener.onLifeCycleEvent(event);
       });
   }

   @Override
   public void run()
   {
      try
      {
         SearchContext ctx = ContextFactory.getSearchContext();
         if (ctx != mParentContext)
         {
            ctx.setUserName(mParentContext.getUserName());
            ctx.setSearchableObject(mParentContext.getSearchableObject());
         }

         raiseEvent(new LifeCycleEvent(LifeCycleEvent.START, org.sixstreams.search.LifeCycleEvent.Phase.INDEX, this));
         while (!mStop)
         {
            while (mDocumentQueue.getSize() > 0)
            {
               IndexableDocument resp = (IndexableDocument) mDocumentQueue.dequeue();
               if (resp != null)
               {
                  sLogger.log(Level.FINE, "Indexing document {0}", resp.getPrimaryKey());
                  processCompositeContent(resp);
                  AbstractIndexer indexer = getIndexer();
                  if (indexer != null)
                  {
                     raiseEvent(new LifeCycleEvent(LifeCycleEvent.PRE_PROCESS, org.sixstreams.search.LifeCycleEvent.Phase.INDEX, resp));
                     indexer.indexDocument(resp);
                     raiseEvent(new LifeCycleEvent(LifeCycleEvent.POST_PROCESS, org.sixstreams.search.LifeCycleEvent.Phase.INDEX, resp));
                  }
                  else
                  {
                     raiseEvent(new LifeCycleEvent(LifeCycleEvent.ERROR, org.sixstreams.search.LifeCycleEvent.Phase.INDEX,
                                                   "No indexer found"));
                  }
               }
               else
               {
                  sLogger.fine("Empty doc from queye, should not happen, here for debugging onlye");
               }
            }

            Thread.sleep(mSleepInterval);
            mBusy = mDocumentQueue.getSize() > 0;
         }
         raiseEvent(new LifeCycleEvent(LifeCycleEvent.COMPLETE, org.sixstreams.search.LifeCycleEvent.Phase.INDEX, this));
         close();
      }
      catch (IndexingException | InterruptedException ie)
      {
         sLogger.log(Level.SEVERE, "Indexing failed", ie);
      }
   }
   //TODO make this a queue based job and handle it asynchronously

   private void processCompositeContent(IndexableDocument indexableDocument)
   {
      SearchContext ctx = ContextFactory.getSearchContext();

      String ctnt = indexableDocument.getContent();

      StringBuffer content = new StringBuffer(ctnt == null? "": ctnt).append(" Attributes: ");

      
      indexableDocument.getDocumentDef().getAttrDefs().stream().filter((attrDef) -> (attrDef.isStored()) //TODO fieldDef.isIndexed
      ).forEach((attrDef) -> {
          content.append(indexableDocument.getAttrValue(attrDef.getName())).append(" ");
       });
      //
      //composite document to be indexed
      //
      indexableDocument.setContent(content.toString());
   }

   public void stop()
   {
      mStop = true;
   }

   public boolean finished()
   {
      return mStop; //done when both are empty
   }

   public void setQueueId(String queueId)
   {
      mQueueId = queueId;
      mDocumentQueue = QueueManager.getQueue(QueueManager.DOCUMENT_QUEUE_NAME + "." + queueId);
   }

   public String getQueueId()
   {
      return mQueueId;
   }
}
