package org.sixstreams.search.data;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;

import org.sixstreams.social.Socialable;


public class DataCommon extends Socialable
{
   @SearchableAttribute(groupName = "contact", sequence = 3)
   private String url;
   @SearchableAttribute(groupName = "profile", sequence = 1)
   private String displayName;
   @SearchableAttribute(groupName = "profile", sequence = 2)
   private String desc;
   //status for the recorde
   private String status;
   @SearchableAttribute(groupName = "auditing", isDisplayable = false)
   private String sourceUrl;

   @SearchableAttribute(groupName = "security", isDisplayable = false)
   private List<String> acl = new ArrayList<String>();

   public void setAcl(List<String> aAcl)
   {
      acl.clear();
      if (aAcl != null)
      {
         acl.addAll(aAcl);
      }
   }

   public List<String> getAcl()
   {
      return acl;
   }

   public void setDesc(String desc)
   {
      this.desc = desc;
   }

   public String getDesc()
   {
      return desc;
   }

   public void setUrl(String url)
   {
      this.url = url;
   }

   public String getUrl()
   {
      return url;
   }

   public void setDisplayName(String displayName)
   {
      this.displayName = displayName;
   }

   public String getDisplayName()
   {
      return this.displayName;
   }


   public void setSourceUrl(String sourceUrl)
   {
      this.sourceUrl = sourceUrl;
   }

   public String getSourceUrl()
   {
      return sourceUrl;
   }

   public void setStatus(String status)
   {
      this.status = status;
   }

   public String getStatus()
   {
      return status;
   }

}
