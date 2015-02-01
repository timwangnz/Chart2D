package org.sixstreams.search.crawl.scheduler;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.LifeCycleEvent;
import org.sixstreams.search.crawl.listener.CrawlListener;
import org.sixstreams.search.crawl.listener.IndexListener;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;

/**
 * A scehdule represents a pre configured job that manages the crawling on one
 * or more searchable objects.
 */
public class Schedule
   implements CrawlListener, IndexListener
{
   public static final String READY = "READY";
   public static final String BUSY = "BUSY";
   public static final String ERROR = "ERROR";

   private ScheduleStatus mScheduleStatus;
   private boolean mDeployed;
   private String mId;
   private long mEngineInstId;
   private String mName;
   private String mDisplayName;
   private List<String> mObjectNames = new ArrayList<String>();
   //
   //statistics
   //
   private long mDocsIndexed = 0;
   private long mDocsCrawled = 0;
   private long mStartedAt, mTimeFinished;
   private double mRate;
   private long mTotalToCrawl;

   /**
    * Removes all the searchable objects within the schedule.
    */
   public void clearSearchableObjects()
   {
      mObjectNames.clear();
   }

   /**
    * Removes searchable object within the schedule by mName. Does
    * nothing if the named object does not exists in the schedule.
    * @param objectName the object mName to be removed.
    */
   public void removeObject(String objectName)
   {
      if (mObjectNames.contains(objectName))
      {
         mObjectNames.remove(mObjectNames);
      }
   }

   /**
    * Adds a searchable objecdt to the schedule.
    * @param object to be added to this schedule.
    */
   public void addObject(SearchableObject object)
   {
      addObject(object.getName());
   }

   public void addObject(String name)
   {
      if (mObjectNames.contains(name))
      {
         return;
      }
      mObjectNames.add(name);
   }

   /**
    * Returns start time for this schedule.
    * @return the start time.
    */
   public long getStartAt()
   {
      return mStartedAt;
   }

   /**
    * Returns a list of searchable objects in this schedule.
    * @return a list of searchable objects.
    */
   public List<SearchableObject> getSearchableObjects()
   {
      List<SearchableObject> list = new ArrayList<SearchableObject>();
      for (String name: mObjectNames)
      {
         SearchableObject obj = MetaDataManager.getSearchableObject(getEngineInstanceId(), name);
         if (obj != null)
         {
            list.add(obj);
         }
      }
      return list;
   }

   /**
    * Sets schedule mId.
    * @param id the identification of this schedule.
    */
   public void setId(String id)
   {
      this.mId = id;
   }

   /**
    * returns schedule mId
    * @return identification of this schedule.
    */
   public String getId()
   {
      return mId;
   }

   /**
    * Sets engine instance this schedule belongs to.
    * @param engineInstId
    */
   public void setEngineInstanceId(long engineInstId)
   {
      this.mEngineInstId = engineInstId;
   }

   /**
    * Returns engine instance id this schedule belongs to.
    * @return engine instance id.
    */
   public long getEngineInstanceId()
   {
      return mEngineInstId;
   }

   /**
    * Sets name for the schedule.
    * @param name of the schedule.
    */
   public void setName(String name)
   {
      this.mName = name;
   }

   /**
    * Returns the name.
    * @return schdule name.
    */
   public String getName()
   {
      return mName;
   }

   /**
    * Sets display name for the schedule.
    * @param displayName.
    */
   public void setDisplayName(String displayName)
   {
      this.mDisplayName = displayName;
   }

   /**
    * Returns display name, if not set, name is returned.
    * @return display name.
    */
   public String getDisplayName()
   {
      return mDisplayName == null? mName: mDisplayName;
   }

   /**
    * Sets deployed flag.
    * @param deployed.
    */
   public void setDeployed(boolean deployed)
   {
      this.mDeployed = deployed;
   }

   /**
    * Returns deployed flag.
    * @return deployed flag.
    */
   public boolean isDeployed()
   {
      return mDeployed;
   }

   /**
    * Returns status of this schedule.
    * @return status of the schedule.
    */
   public ScheduleStatus getScheduleStatus()
   {
      return mScheduleStatus;
   }

   /**
    * Sets status for this schedule.
    * @param status.
    */
   public void setScheduleStatus(String status)
   {
      mScheduleStatus = new ScheduleStatus();
      mScheduleStatus.setStatus(status);
   }

   /**
    * @inheritDoc
    */
   public void onLifeCycleEvent(LifeCycleEvent event)
   {
      Object eventObject = event.getObject();
      if (eventObject instanceof Throwable)
      {
         ((Throwable) eventObject).printStackTrace();
      }

      if (event.getPhase().equals(org.sixstreams.search.LifeCycleEvent.Phase.CRAWL))
      {
         if (eventObject instanceof IndexableDocument && event.getEventType().equals(LifeCycleEvent.POST_PROCESS))
         {
            mDocsCrawled++;
         }

         if (event.getEventType().equals(LifeCycleEvent.START))
         {
            mStartedAt = System.currentTimeMillis();
            mDocsCrawled = 0;
            mDocsIndexed = 0;
            mRate = 0;
            //setScheduleStatus(READY);
         }
      }

      if (event.getPhase().equals(org.sixstreams.search.LifeCycleEvent.Phase.INDEX))
      {

         if (eventObject instanceof IndexableDocument && event.getEventType().equals(LifeCycleEvent.POST_PROCESS))
         {
            mDocsIndexed++;
            mRate = 1000 * mDocsIndexed / (System.currentTimeMillis() - mStartedAt);
         }

         if (eventObject instanceof IndexableDocument && event.getEventType().equals(LifeCycleEvent.COMPLETE))
         {
            Calendar calendar = Calendar.getInstance();
            calendar.setTimeInMillis(mStartedAt);
            mScheduleStatus.setLastCrawled(calendar);
            mTimeFinished = System.currentTimeMillis();
            mTotalToCrawl = mDocsCrawled;
         }
      }
   }

   /**
    * Returns number of documents indexed.
    * @return number of documents indexed.
    */
   public long getDocsIndexed()
   {
      return mDocsIndexed;
   }

   /**
    * Returns number of docuemnts retrieved.
    * @return number of documents retrieved for this schedule.
    */
   public long getDocsCrawled()
   {
      return mDocsCrawled;
   }

   /**
    * String representation of this schedule.
    * @return status of this schedule.
    */
   public String toString()
   {
      StringBuffer string = new StringBuffer();
      if (mScheduleStatus != null)
      {
         string.append(mScheduleStatus.getStatus()); //last time crawled
         if (mDocsCrawled > 0)
         {
            string.append(", ").append(mDocsCrawled).append(" crawled");
         }
         if (mDocsIndexed > 0)
         {
            string.append(", ").append(mDocsIndexed).append(" indexed at a rate of ").append(mRate *
                                                                                             3600).append(" docs/hour");
         }
         string.append(".");
      }
      return string.toString();
   }

   public long getTimeFinished()
   {
      return mTimeFinished;
   }

   public double getRate()
   {
      return mRate;
   }

   public long getTotalToCrawl()
   {
      return mTotalToCrawl;
   }

}
