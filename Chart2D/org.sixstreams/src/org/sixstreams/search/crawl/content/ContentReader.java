package org.sixstreams.search.crawl.content;

import java.io.IOException;

import java.util.List;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.crawl.crawler.CrawlableImpl;


/**
 * Responsible for reading content of a document and parse it into a common
 * indexable content. e.g. a pdf content reader would read pdf file and generate
 * a body of text that can be indexed.
 */
public interface ContentReader
{
   /**
    * Provides a list of mime types this reader supports.
    * @return list of mine types supported by this reader.
    */
   public List<String> getSupportedContentTypes();

   /**
    * Sets runtime content type for the reader. This type must be
    * one of the supported mime types.
    * @param contentType the mime type for this instance.
    */
   public void setContentType(String contentType);

   /**
    * Process content object and convert it into an IndexableDocument
    * @param crawlable location where the content comes from
    * @param content the content object of any type, must be one of the types
    * supported by this reader
    * @return an IndexableDocument created from content passed in.
    */
   public IndexableDocument process(CrawlableImpl crawlable, Object content);

   /**
    * Reads content into a String.
    * @param content the object to be converted into a string
    * @return string representation of the content.
    * @throws IOException
    */
   public StringBuffer read(Object content)
      throws IOException;

   /**
    * Clean up the reader before exits.
    * @throws IOException
    */
   void close()
      throws IOException;
}
