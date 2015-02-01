package org.sixstreams.search.util.queue;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

public class QueueImpl
   implements Queue
{
   private static Logger sLogger = Logger.getLogger(QueueImpl.class.getName());
   private static long logModule = 100;
   //  private List<Object> mData = Collections.synchronizedList(new LinkedList<Object>());
   private Map<String, Object> mData = new HashMap<String, Object>();
   private Map<String, Object> mVisited = new HashMap<String, Object>();
   private Object writeBlock = new Object();
   private String mName;
   private long mTotalEnqueued;
   private long mTotalDequeued;
   private long mDesiredSize = 10000;

   public QueueImpl(String name)
   {
      mName = name;
   }

   private void checkSize()
   {
      //we want to limit the queue size so that dequeuers have enough
      //time to match the enqueuer
      if (mData.size() > mDesiredSize)
      {
         synchronized (writeBlock)
         {
            while (true)
            {
               try
               {
                 
				  Thread.sleep(50L);
                  if (mData.size() < mDesiredSize * 0.9)
                  {
                     break;
                  }
               }
               catch (InterruptedException ie)
               {
                  // TODO: Add catch code
                  ie.printStackTrace();
               }

            }
         }
      }
   }

   public void enqueue(String url, Object item)
   {
      //we only want size to be certain
      checkSize();
      synchronized (writeBlock)
      {
         if (mData.get(url) != null)
         {
            //sLogger.info(url + " is already in queued");
            return;
         }
         if (mVisited.get(url) != null)
         {
            //this item has been processed
            return;
         }

         mData.put(url, item);
         mTotalEnqueued++;
         sLogger.info(mTotalEnqueued + "\t " + item + " queued");
         if (mTotalEnqueued % logModule == 0)
         {
            sLogger.info(item + " queue status - Total Enqueued:" + mTotalEnqueued);
         }
      }
   }

   public long getSize()
   {
      return mData.size();
   }

   public long getTotalEnqueued()
   {
      return mTotalEnqueued;
   }

   public long getTotalDequeued()
   {
      return mTotalDequeued;
   }

   public synchronized Object dequeue()
   {
      if (mData.size() == 0)
      {
         return null;
      }

      String queueKey = mData.keySet().iterator().next();
      Object queuedItem = mData.get(queueKey);
      mData.remove(queueKey);
      mTotalDequeued++;
      mVisited.put(queueKey, queuedItem);
      if (mTotalDequeued % logModule == 0)
      {
         sLogger.info(mName + " queue status - Total Dequeued:" + mTotalDequeued + " Current Queue Size:" +
                      mData.size());
      }

      return queuedItem;
   }

   public boolean isEmpty()
   {
      return mData.size() == 0;
   }
}
