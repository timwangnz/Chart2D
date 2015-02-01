package org.sixstreams.search;

import java.io.IOException;
import java.io.Writer;


/**
 * This class overrides all methods of Writer and
 *  delegates to the passed in writer.
 * <p>
 * A search engine should implement an indexer with its internal index mechanism.
 */
public abstract class IndexableWriter
   extends Writer
{

   Writer writer;

   public IndexableWriter(Writer writer)
   {
      super();
      this.writer = writer;

   }

   public IndexableWriter()
   {

   }

   public void write(int c)
      throws IOException
   {
      writer.write(c);
   }

   public void write(char[] cbuf)
      throws IOException
   {
      writer.write(cbuf);
   }

   public void write(char[] cbuf, int off, int len)
      throws IOException
   {
      writer.write(cbuf, off, len);
   }

   public void write(String str)
      throws IOException
   {
      writer.write(str);
   }

   public void write(String str, int off, int len)
      throws IOException
   {
      writer.write(str, off, len);
   }

   public void flush()
      throws IOException
   {
      writer.flush();
   }

   public void close()
      throws IOException
   {
      writer.close();
   }

   public abstract void writeIndexable(SearchContext ctx, IndexableDocument doc);
}
