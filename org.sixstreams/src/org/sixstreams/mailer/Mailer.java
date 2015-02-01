package org.sixstreams.mailer;

import java.io.IOException;

public class Mailer
{
  public Mailer()
  {
    super();
  }

  public static Mailer getInstance()
  {
    
    return new Mailer();
  }

  public void sendMail(String address, Object object, String subject, String message) throws IOException
  {
    //AmazonMailer amazonMailer = new AmazonMailer();
  }
}
