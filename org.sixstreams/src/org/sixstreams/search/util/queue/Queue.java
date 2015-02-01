package org.sixstreams.search.util.queue;


public interface Queue
{
   void enqueue(String url, Object obj);

   Object dequeue();

   boolean isEmpty();

   long getSize();
}
