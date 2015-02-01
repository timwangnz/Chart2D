package org.sixstreams.search.crawl.web;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.tags.TitleTag;

public class TitleFilterImpl
   implements NodeFilter
{
   private static final long serialVersionUID = 1L;

   public boolean accept(Node node)
   {
      if (node instanceof TitleTag)
      {
         return true;
      }
      else
      {
         return false;
      }
   }
}
