package org.sixstreams.app.data.crawlers;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

public abstract class TextCrawler
{
 
   protected long maxRecordsToCrawl = 20000;
   protected long logInterval = maxRecordsToCrawl / 10;
   protected String dateFormat = "MM-dd-yyyy";
   SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);

   protected String delimitor = "\",";
   protected char cDelimitor = ',';
   protected boolean withQuotes;
   private long totalCrawled = 0;

   private String[] headers;

   protected abstract Object toObject(Map<String, String> map);

   public void sniff(File file, int maxLength)
   {
      FileReader fileReader;
      try
      {
         fileReader = new FileReader(file);
         int cint = fileReader.read();
         StringBuffer line = new StringBuffer();

         int count = 0;
         while (cint != -1)
         {
            char c = (char) cint;

            line.append(c);

            count++;
            if (count > maxLength)
            {
               break;
            }
            cint = fileReader.read();
         }
         System.err.println(line);
      }
      catch (Exception e)
      {
         e.printStackTrace();
      }
   }
   
   public void crawl(File file)
   {
      FileReader fileReader;
      try
      {
         fileReader = new FileReader(file);
         BufferedReader bf = new BufferedReader(fileReader);
         parseHeader(bf.readLine());
         String line = bf.readLine();
         while (line != null)
         {
            if(toObject(parseLine(line)) != null)
            {
            	totalCrawled++;
            }
            if (totalCrawled >= maxRecordsToCrawl)
            {
               break;
            }
            line = bf.readLine();
         }
      }
      catch (Exception e)
      {
         e.printStackTrace();
      }
   }

   public long getMaxRecordsToCrawl()
   {
      return maxRecordsToCrawl;
   }

   public void setMaxRecordsToCrawl(long maxRecordsToCrawl)
   {
      this.maxRecordsToCrawl = maxRecordsToCrawl;
   }

   public long getLogInterval()
   {
      return logInterval;
   }

   public void setLogInterval(long logInterval)
   {
      this.logInterval = logInterval;
   }

   public String getDateFormat()
   {
      return dateFormat;
   }

   public void setDateFormat(String dateFormat)
   {
      this.dateFormat = dateFormat;
   }

   public String getDelimitor()
   {
      return delimitor;
   }

   public void setDelimitor(String delimitor)
   {
      this.delimitor = delimitor;
   }

   public char getcDelimitor()
   {
      return cDelimitor;
   }

   public void setcDelimitor(char cDelimitor)
   {
      this.cDelimitor = cDelimitor;
   }

   public long getTotalCrawled()
   {
      return totalCrawled;
   }

   public void setTotalCrawled(long totalCrawled)
   {
      this.totalCrawled = totalCrawled;
   }

   public String[] getHeaders()
   {
      return headers;
   }

   public void setHeaders(String[] headers)
   {
      this.headers = headers;
   }

   public void setQuotes(boolean withQuotes)
   {
      this.withQuotes = withQuotes;
   }
   
   private void parseHeader(String line)
   {
      headers = line.split(delimitor);
      if (this.withQuotes)
      {
         for (int i = 0; i < headers.length; i++)
         {
            headers[i] = headers[i].substring(1, headers[i].length());
         }
      }
   }
   private Map<String, String> parseLine(String line)
   {
      String[] values = line.split(delimitor);
      if (this.withQuotes)
      {
         for (int i = 0; i < values.length; i++)
         {
        	 values[i] = values[i].substring(1, values[i].length());
         }
      }
      Map<String, String> object = new HashMap<String, String>();
      int count = 0;
      for (String key: headers)
      {
    	  if (key == null)
    	  {
    		  key = "";
    	  }
    	  String value = values[count++];
    	  if (value == null)
    	  {
    		  value = "";
    	  }
         object.put(key, value);
      }
      return object;
   }
/*
 * 
   
      private String getStringValue(String value)
   {
      if (value == null || value.length() == 0)
      {
         return value;
      }
      if (this.withQuotes) //remove quotes
      {
         value = value.substring(1, value.length() - 1);
      }
      return value;
   }
   private String[] toArray(String line)
   {
      byte[] bytes = line.getBytes();
      StringBuffer stringValue = new StringBuffer();
      int count = 0;
      int length = Integer.valueOf(headers.length);
      String[] values = new String[length];
      for (byte b: bytes)
      {
         char c = (char) b;
         if (c == cDelimitor)
         {
            values[count] = getStringValue(stringValue.toString());
            stringValue = new StringBuffer();
            count++;
         }
         else
         {
            stringValue.append(c);
         }
         if (count == headers.length)
         {
            break;
         }
      }
      return values;
   }

   private Map<String, String> parseLine(String line)
   {
      String[] values = toArray(line);
      Map<String, String> object = new HashMap<String, String>();
      int count = 0;
      for (String key: headers)
      {
    	  if (key == null)
    	  {
    		  key = "";
    	  }
    	  String value = values[count++];
    	  if (value == null)
    	  {
    		  value = "";
    	  }
         object.put(key, value);
      }
      return object;
   }
*/
}
