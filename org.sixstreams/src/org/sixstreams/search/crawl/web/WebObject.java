package org.sixstreams.search.crawl.web;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;


@Searchable(title = "title")
public class WebObject
{
   String url;
   String title;
   String content;

   public void setUrl(String url)
   {
      this.url = url;
   }

   @SearchableAttribute(isKey = true)
   public String getUrl()
   {
      return url;
   }

   public void setContent(String content)
   {
      this.content = content;
   }

   @SearchableAttribute
   public String getContent()
   {
      return content;
   }

   public void setTitle(String title)
   {
      this.title = title;
   }

   @SearchableAttribute
   public String getTitle()
   {
      return title;
   }
}
