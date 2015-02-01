package org.sixstreams.search;

import java.util.List;

/**
 * Crawlables are objects that can be crawled by a search engine. It contains
 * an indexable document, and a list of URLs that will lead to other crawlables.
 *
 * <p>An example of crawlable is an HTML page where it contains a list of
 * URLs that can be used to reteive other document as well as its own mContent
 * that can be used.
 *
 * <p>A crawler can normally work with a crawlable. It will use an index
 * to index its mContent, and queue the URLs to other crawlers to retrieve
 * crawlables.
 */
public interface Crawlable
{

   /**
    * Returns indexable document for a given doc id.
    * @param docId document id of an indexable document.
    */
   IndexableDocument getDocument(String docId);

   /**
    * Returns a list of documents that this crawlable is linked to.
    * @return list of documents.
    */
   List<Crawlable> getCrawlables();
}
