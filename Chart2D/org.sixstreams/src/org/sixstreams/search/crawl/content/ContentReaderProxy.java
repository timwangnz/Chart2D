package org.sixstreams.search.crawl.content;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.util.ClassUtil;

/**
 * Proxy reader should be used by consumers of ContentReader.
 */
public class ContentReaderProxy
   extends AbstractReader
{
   private static final String PDFReaderClass = "org.sixstreams.search.crawl.reader.HTMLContentReader";
   private static final String HTMLReaderClass = "org.sixstreams.search.crawl.reader.PDFContentReader";
   private static final String MSReaderClass = "org.sixstreams.search.crawl.reader.MicorsoftContentReader";

   private ContentReader reader;

   private static Map<String, String> readerRegistry = new HashMap<String, String>();

   public static void registerReader(String mimeType, String clazzName)
   {
      readerRegistry.put(mimeType, clazzName);
   }

   public static void registerReader(String mimeType, Class<?> clazz)
   {
      registerReader(mimeType, clazz.getName());
   }

   public static StringBuffer read(File file)
   {
      ContentReader reader = getContentReader(file);
      try
      {
         FileInputStream fi = new FileInputStream(file);
         StringBuffer sb = reader.read(fi);
         fi.close();
         return sb;
      }
      catch (FileNotFoundException fnfe)
      {
         // TODO: Add catch code
         fnfe.printStackTrace();
      }
      catch (IOException ioe)
      {
         // TODO: Add catch code
         ioe.printStackTrace();
      }
      return new StringBuffer();
   }
   //find content type if not given by sniffing the content stream

   public static String sniff4ContentType(InputStream contentStream)
   {
      byte[] first100 = new byte[100];
      String contentType = "text/plain";
      try
      {
         contentStream.read(first100, 0, 100);
         String header = new String(first100);
         if (header.contains("PDF"))
         {
            contentType = "application/pdf";
         }
         //TODO algorithm to find out a proper reader
      }
      catch (IOException ioe)
      {
         //TODO: Add catch code
         ioe.printStackTrace();
      }
      return contentType;
   }

   private static ContentReader getReader(String name)
   {
      return (ContentReader) ClassUtil.create(name);
   }

   private static ContentReader getContentReader(File file)
   {
      String contentType = "plain/text";

      String fileName = file.getName();
      String ext = fileName.substring(fileName.lastIndexOf("."));

      if (ext.endsWith("pdf"))
      {
         return getReader(PDFReaderClass);
      }
      if (ext.endsWith("ppt"))
      {
         return getReader(MSReaderClass);
      }
      if (ext.endsWith("doc"))
      {
         return getReader(MSReaderClass);
      }
      if (ext.endsWith("xls"))
      {
         return getReader(MSReaderClass);
      }
      if (ext.equalsIgnoreCase("html"))
      {
         return getReader(HTMLReaderClass);
      }
      return getContentReader(contentType);
   }


   private static ContentReader getContentReader(String contentType)
   {
      for (String reader: readerRegistry.keySet())
      {
         if (reader.equals(contentType))
         {
            String readerClass = readerRegistry.get(reader);
            try
            {
               return (ContentReader) Thread.currentThread().getContextClassLoader().loadClass(readerClass).newInstance();
            }
            catch (Exception iae)
            {
               // TODO: Add catch code
               iae.printStackTrace();
            }
         }
      }

      return new TextReader();
   }

   public ContentReaderProxy(String contentType)
   {
      reader = getContentReader(contentType);
   }

   public List<String> getSupportedContentTypes()
   {
      if (reader != null)
      {
         return reader.getSupportedContentTypes();
      }
      else
      {
         return Collections.emptyList();
      }
   }

   public StringBuffer read(Object object)
      throws IOException
   {
      //read from contentSteam
      if (reader != null)
      {
         return reader.read(object);
      }
      else
      {
         return new StringBuffer();
      }
   }

   public void setContentType(String contentType)
   {
      if (reader != null)
      {
         reader.setContentType(contentType);
      }
   }

   public void close()
      throws IOException
   {
      if (reader != null)
      {
         reader.close();
      }
   }
}
