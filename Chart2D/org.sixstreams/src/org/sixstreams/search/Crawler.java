package org.sixstreams.search;

import org.sixstreams.search.meta.SearchableObject;

/**
 * A crawler is repsonsible for creating crawlables from an accessible URL.
 * <p>
 * Once it retrieves a document, it passes the document to the indexer. In
 *  most cases, a crawlable document would contain a list of URLs that forms
 *  a crawlable topology. Each crawler is responsible for retrieve one document
 *  at a time.
 *
 *  The URLs are handed to other crawlers to repeat this
 *  crawling process. So the topology is not crawled by one crawler, but a
 *  bunch of them.
 *  <p>The crawling process will stop once all URLs are crawled.
 *
 *  <p>In AppSearch, an implemenation of this interface will be basically
 *  a wrap on top of search engine crawling functionality.
 *
 */
public interface Crawler
{

   /**
    * Starts the crawler.
    * @param incremental indicates whether this is a incremental crawl
    * request or not.
    */
   void start(boolean incremental);

   /**
    * Sets searchable object to crawl.
    * @param searchableObject
    */
   void setSearchableObject(SearchableObject searchableObject);

}
