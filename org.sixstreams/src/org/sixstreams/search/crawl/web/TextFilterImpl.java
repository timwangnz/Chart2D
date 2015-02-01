package org.sixstreams.search.crawl.web;

import org.htmlparser.Node;
import org.htmlparser.Text;
import org.htmlparser.filters.StringFilter;

public class TextFilterImpl
   extends StringFilter
{
   private static final long serialVersionUID = 1L;

   public boolean accept(Node node)
   {

      return node instanceof Text;

   }
}
