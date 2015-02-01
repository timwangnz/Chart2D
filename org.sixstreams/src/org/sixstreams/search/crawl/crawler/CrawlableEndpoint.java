package org.sixstreams.search.crawl.crawler;

/**
 * Represents an access point of data source destination.
 */
public class CrawlableEndpoint
{

   private int level;
   private String url;
   private Throwable error;
   private Object customObject;

   public CrawlableEndpoint(String url, int level)
   {
      this.level = level;
      this.url = url;
   }

   // more info might be added here

   public void setLevel(int level)
   {
      this.level = level;
   }

   public int getLevel()
   {
      return level;
   }

   public void setUrl(String url)
   {
      this.url = url;
   }

   public String getUrl()
   {
      return url;
   }

   public int hashCode()
   {
      return url.hashCode();
   }

   public void setError(Throwable error)
   {
      this.error = error;
   }

   public Throwable getError()
   {
      return error;
   }

   public String toString()
   {
      return url;
   }

   /**
    * Sets host object that the end point is drived from. e.g. LinkTag
    *
    * @param customObject
    *            host object for the end point
    */
   public void setCustomObject(Object customObject)
   {
      this.customObject = customObject;
   }

   /**
    * Returns the host object for the end point. This value might be used by
    * down stream processor to anayalize the end point with extra information
    * */
   public Object getCustomObject()
   {
      return customObject;
   }
}
