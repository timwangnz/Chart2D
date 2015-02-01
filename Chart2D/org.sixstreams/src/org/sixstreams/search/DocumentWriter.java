package org.sixstreams.search;


public interface DocumentWriter
{
   public StringBuffer toString(String format, IndexedDocument object);

   public boolean handleFormat(String format);
}
