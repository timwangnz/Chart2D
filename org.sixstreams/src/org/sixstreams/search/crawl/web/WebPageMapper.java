package org.sixstreams.search.crawl.web;


import org.sixstreams.search.Crawler;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.crawl.crawler.ContentMapper;
import org.sixstreams.search.crawl.crawler.CrawlableEndpoint;
import org.sixstreams.search.crawl.crawler.GraphAnalyzer;
import org.sixstreams.search.data.PersistenceManager;

import org.htmlparser.Node;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.NodeList;

public class WebPageMapper
   implements ContentMapper, GraphAnalyzer
{
   Crawler crawler;

   public IndexableDocument createIndexableDocument(String url, Object content)
   {

      WebObject webObject = new WebObject();
      webObject.setUrl(url);
      populate(webObject, content);
      IndexableDocument doc = PersistenceManager.createDocument(webObject);

      return doc;
   }

   public void populate(WebObject webObject, Object content)
   {
      if (content instanceof NodeList)
      {
         NodeList nodeList = (NodeList) content;

         NodeList text = nodeList.extractAllNodesThatMatch(new TextFilterImpl(), true);

         StringBuffer contentBuffer = new StringBuffer();
         for (Node node: text.toNodeArray())
         {
            String stringValue = node.toPlainTextString();

            if (stringValue != null && stringValue.trim().length() > 0)
            {
               contentBuffer.append(stringValue.trim()).append(" ");
            }
         }
         webObject.setContent(contentBuffer.toString());
         text = nodeList.extractAllNodesThatMatch(new TitleFilterImpl(), true);
         contentBuffer = new StringBuffer();

         for (Node node: text.toNodeArray())
         {
            String stringValue = node.toPlainTextString();

            if (stringValue != null && stringValue.trim().length() > 0)
            {
               contentBuffer.append(stringValue.trim()).append(" ");
            }
         }

         webObject.setTitle(contentBuffer.toString());
         //weight
         //figure out other people reference to this page
         //figure out level
         //
         //get language
         //get keywords
         //get other metadata
      }
      // System.err.println(mTitle + "  " + mContent);
   }

   public GraphAnalyzer getGraphAnalyzer(String url)
   {
      return this;
   }

   public boolean isChildCrawlable(CrawlableEndpoint crawlableEndpoint, Object object)
   {
      if (object instanceof LinkTag)
      {
         return true;
      }
      else
      {
         return false;
      }
   }

   public void setCrawler(Crawler crawler)
   {
      this.crawler = crawler;
   }

   public Crawler getCrawler()
   {
      return crawler;
   }
}
