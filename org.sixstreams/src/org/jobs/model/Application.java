package org.jobs.model;

import java.util.Date;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "status")
public class Application
   extends IdObject
{
   private Date dateApplied;
   
   private String applicant;
   private String resume;
   private String job;
   private String coverLetter;
   
   private String status;
   public Date getDateApplied()
   {
      return dateApplied;
   }

   public void setDateApplied(Date dateApplied)
   {
      this.dateApplied = dateApplied;
   }

   public String getApplicant()
   {
      return applicant;
   }

   public void setApplicant(String candidate)
   {
      this.applicant = candidate;
   }

   public String getResume()
   {
      return resume;
   }

   public void setResume(String resume)
   {
      this.resume = resume;
   }

   public String getJob()
   {
      return job;
   }

   public void setJob(String job)
   {
      this.job = job;
   }

   public String getCoverLetter()
   {
      return coverLetter;
   }

   public void setCoverLetter(String coverLetter)
   {
      this.coverLetter = coverLetter;
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
