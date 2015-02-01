package org.jobs.model;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.social.SocialLocatable;

@Searchable(title = "name")
public class Employer
   extends SocialLocatable
{
   private String name;
   
   @SearchableAttribute(facetName = "industry", facetPath = "industry", lov="org.jobs.model.JobIndustryLov")
   private String industry;
   
   private String subIndustry;

   public String getName()
   {
      return name;
   }

   public void setName(String name)
   {
      this.name = name;
   }

   public String getIndustry()
   {
      return industry;
   }

   public void setIndustry(String industry)
   {
      this.industry = industry;
   }

   public String getSubIndustry()
   {
      return subIndustry;
   }

   public void setSubIndustry(String subIndustry)
   {
      this.subIndustry = subIndustry;
   }
}
