package org.sixstreams.search.crawl.web;

import org.htmlparser.Node;
import org.htmlparser.filters.StringFilter;
import org.htmlparser.tags.TableRow;

public class RowFilterImpl
   extends StringFilter
{
   private static final long serialVersionUID = 1L;

   public boolean accept(Node node)
   {

      return node instanceof TableRow;

   }
}
