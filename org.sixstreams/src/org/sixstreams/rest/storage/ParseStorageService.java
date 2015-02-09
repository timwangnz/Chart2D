/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.sixstreams.rest.storage;

import java.util.List;
import org.sixstreams.search.Administrator;
import org.sixstreams.search.Crawler;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.Indexer;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.Searcher;
import org.sixstreams.search.meta.SearchableObject;

/**
 *
 * @author anpwang
 */
public class ParseStorageService implements SearchEngine {

    @Override
    public Administrator getAdministrator() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public String getDescription() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Searcher getSearcher() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Crawler getCrawler() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Indexer getIndexer() {
        return new ParseIndexer();
    }

    @Override
    public IndexableDocument createIndexableDocument(SearchableObject searchableObject) {
        return null;
    }

    @Override
    public void cleanup() {
        //To change body of generated methods, choose Tools | Templates.
    }

    public static class ParseIndexer implements Indexer {

        @Override
        public void indexDocument(IndexableDocument document) throws IndexingException {
            
        }

        @Override
        public void indexBatch(List<IndexableDocument> document) throws IndexingException {
            
        }
        private SearchableObject searchableObject;
        @Override
        public void setSearchableObject(SearchableObject searchableObject) throws IndexingException {
            this.searchableObject = searchableObject;
        }

        @Override
        public void close() throws IndexingException {
            //nothing to do
        }

        @Override
        public void createIndex() throws IndexingException {
        //dont have to do anything    
        }

        @Override
        public void deleteIndex() {
            //delete the table
        }

    }
}
