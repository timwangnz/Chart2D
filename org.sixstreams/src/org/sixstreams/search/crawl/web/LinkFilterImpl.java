package org.sixstreams.search.crawl.web;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.tags.LinkTag;

public class LinkFilterImpl
   implements NodeFilter
{

   private static final long serialVersionUID = 1L;

   public boolean accept(Node node)
   {
      if (node instanceof LinkTag)
      {
         return true;
      }
      else
      {
         return false;
      }
   }
}
