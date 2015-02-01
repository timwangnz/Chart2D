package org.sixstreams.search.crawl.crawler;

import org.sixstreams.search.Crawler;
import org.sixstreams.search.IndexableDocument;

public interface ContentMapper
{
   public IndexableDocument createIndexableDocument(String url, Object content);

   public Crawler getCrawler();

   public void setCrawler(Crawler crawler);

   public GraphAnalyzer getGraphAnalyzer(String url);
}
