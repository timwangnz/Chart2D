package org.sixstreams.social;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "subject")
public class Message extends IdObject
{
   private String toId;
   private String toName;
   //message id this message is replying to
   private String replyTo;
   private String subject;
   private String body;

   public void setToId(String toId)
   {
      this.toId = toId;
   }

   public String getToId()
   {
      return toId;
   }

   public void setToName(String toName)
   {
      this.toName = toName;
   }

   public String getToName()
   {
      return toName;
   }

   public void setSubject(String subject)
   {
      this.subject = subject;
   }

   public String getSubject()
   {
      return subject;
   }

   public void setBody(String body)
   {
      this.body = body;
   }

   public String getBody()
   {
      return body;
   }

public void setReplyTo(String replyTo)
{
	this.replyTo = replyTo;
}

public String getReplyTo()
{
	return replyTo;
}
}
