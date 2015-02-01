package org.sixstreams.search.crawl.web;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.tags.ImageTag;

public class ImgFilterImpl
   implements NodeFilter
{


   public boolean accept(Node node)
   {
      if (node instanceof ImageTag)
      {
         return true;
      }
      else
      {
         return false;
      }
   }
}
