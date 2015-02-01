package org.sixstreams.search.crawl.web;

import org.sixstreams.search.crawl.crawler.IndexableDocumentImpl;

import org.htmlparser.Node;
import org.htmlparser.util.NodeList;


public class IndexableWebpage
   extends IndexableDocumentImpl
{

   public IndexableWebpage(String url)
   {
      super(url);
   }

   public void populate(Object content)
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
         setContent(contentBuffer.toString());
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

         setTitle(contentBuffer.toString());
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

}
