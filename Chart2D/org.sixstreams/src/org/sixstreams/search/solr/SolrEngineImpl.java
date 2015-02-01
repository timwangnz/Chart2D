package org.sixstreams.search.solr;

import org.sixstreams.search.Constants;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.meta.SearchableObject;

import org.apache.solr.client.solrj.SolrServer;

public abstract class SolrEngineImpl
   implements SearchEngine, Constants
{
   public abstract SolrServer getSolrServer(SearchableObject searchableObject);
}
