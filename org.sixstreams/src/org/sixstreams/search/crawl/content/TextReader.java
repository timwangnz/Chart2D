package org.sixstreams.search.crawl.content;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.util.ArrayList;
import java.util.List;

public class TextReader
   extends AbstractReader
{
   public List<String> getSupportedContentTypes()
   {
      List<String> types = new ArrayList<String>();
      types.add("text/plain");
      return types;
   }

   public StringBuffer read(Object object)
      throws IOException
   {
      InputStreamReader inR = new InputStreamReader((InputStream) object);
      BufferedReader buf = new BufferedReader(inR);

      String line;
      StringBuffer sb = new StringBuffer();
      while ((line = buf.readLine()) != null)
      {
         sb.append(line);
      }

      //System.err.println("Attachment:" + sb);
      return sb;
   }


   public void close()
   {
   }
}
