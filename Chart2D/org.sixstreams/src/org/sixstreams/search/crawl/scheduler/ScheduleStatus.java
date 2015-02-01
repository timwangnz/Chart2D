package org.sixstreams.search.crawl.scheduler;

import java.util.Calendar;

public class ScheduleStatus
{
   private String status;
   private Calendar lastCrawled;

   public Calendar getLastCrawled()
{
	return lastCrawled;
}

public void setStatus(String status)
   {
      this.status = status;
   }

   public void setLastCrawled(Calendar calendar)
   {
      lastCrawled = calendar;
   }

   public String getStatus()
   {
      return status;
   }
}
