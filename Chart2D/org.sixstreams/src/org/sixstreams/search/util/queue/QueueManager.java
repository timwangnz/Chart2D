package org.sixstreams.search.util.queue;

import java.util.Hashtable;
import java.util.Map;

public class QueueManager
{
   public static final String URL_QUEUE_NAME = "URL";
   public static final String DATA_FEED_QUEUE_NAME = "DataFeedQueue";
   public static final String DOCUMENT_QUEUE_NAME = "DocumentQueue";
   public static final String COMPOSITE_DOCUMENT_QUEUE_NAME = "CompositeDocumentQueue";

  
   static Map<String, Queue> mQueues = new Hashtable<String, Queue>();


   private QueueManager()
   {

   }

   public static Queue getQueue(String name)
   {
      Queue queue = mQueues.get(name);
      if (queue == null)
      {
         synchronized (mQueues)
         {
            queue = mQueues.get(name);
            if (queue == null)
            {
               queue = new QueueImpl(name);
               mQueues.put(name, queue);
            }
         }
      }
      return queue;
   }
}
