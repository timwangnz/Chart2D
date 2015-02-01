package org.sixstreams.social;

import org.sixstreams.rest.IdObject;

public class SocialTag extends IdObject
{
   private String name;
   private long count;
   private String subjectClass;

   public String getContent()
   {
      return name;
   }

   public String toString()
   {
      if (subjectClass != null)
      {
         return "Tag: " + name + "(" + count + ") on " + subjectClass;
      }
      else
      {
         return "Tag: " + name + "(" + count + ") ";
      }
   }

   public void setCount(long count)
   {
      this.count = count;
   }


   public long getCount()
   {
      return count;
   }

   public void setName(String name)
   {
      this.name = name;
   }


   public String getName()
   {
      return name;
   }

   public void setSubjectClass(String subjectClass)
   {
      this.subjectClass = subjectClass;
   }

   public String getSubjectClass()
   {
      return subjectClass;
   }
}
