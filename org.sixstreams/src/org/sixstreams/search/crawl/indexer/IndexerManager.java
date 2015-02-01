package org.sixstreams.search.crawl.indexer;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import java.util.List;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.Attachment;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.LifeCycleEvent;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.crawl.content.ContentReader;
import org.sixstreams.search.crawl.content.ContentReaderProxy;
import org.sixstreams.search.crawl.listener.DocumentListener;
import org.sixstreams.search.crawl.listener.IndexListener;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.queue.Queue;
import org.sixstreams.search.util.queue.QueueManager;

/**
 * Indexing Job Manager. Internal class
 */
public class IndexerManager
   implements Runnable
{
   private static Logger sLogger = Logger.getLogger(IndexerManager.class.getName());

   private List<IndexListener> mListeners = new Vector<IndexListener>();

   private List<AbstractIndexer> mIndexers = new Vector<AbstractIndexer>();
   private List<DocumentListener> mDocumentListeners = new Vector<DocumentListener>();
   private int mSleepInterval = 50;
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

   public void addDocumentListener(DocumentListener listener)
   {
      mDocumentListeners.add(listener);
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
      for (AbstractIndexer indexer: mIndexers)
      {
         indexer.close();
      }
   }

   private void raiseEvent(LifeCycleEvent event)
   {
      for (IndexListener listener: mListeners)
      {
         listener.onLifeCycleEvent(event);
      }
   }

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
                  sLogger.fine("Indexing document " + resp.getPrimaryKey());
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
      catch (Exception ie)
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

      
      for (AttributeDefinition attrDef: indexableDocument.getDocumentDef().getAttrDefs())
      {
         if (attrDef.isStored()) //TODO fieldDef.isIndexed
         {
             content.append(indexableDocument.getAttrValue(attrDef.getName())).append(" ");
         }
      }

      //TODO move to composite module
      for (Attachment attachment: indexableDocument.getAttachments())
      {
         // AttachmentImpl impl = (AttachmentImpl)attachment;
         ByteArrayOutputStream out = new ByteArrayOutputStream();
         try
         {
            //TODO handle large documents
            //TODO this might need to be asynchronous
            attachment.read(ctx, out);

            InputStream in = new ByteArrayInputStream(out.toByteArray());
            String contentType = ContentReaderProxy.sniff4ContentType(in);
            ContentReader reader = new ContentReaderProxy(contentType);
            StringBuffer sb = reader.read(in);

            if (sb != null && sb.toString().trim().length() > 0)
            {
               content.append("\nAttachment - ").append(attachment.getPrimaryKey()).append("\n");
               content.append(sb);
            }

            reader.close();
         }
         catch (Exception ioe)
         {
            sLogger.log(Level.SEVERE, "Failed to read attachment", ioe);
         }
         finally
         {
            try
            {
               out.close();
            }
            catch (IOException ioe)
            {
               sLogger.log(Level.SEVERE, "Failed to close stream", ioe);
            }
         }
      }
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
