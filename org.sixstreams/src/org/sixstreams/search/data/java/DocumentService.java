package org.sixstreams.search.data.java;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.Constants;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.Document;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.Indexer;
import org.sixstreams.search.IndexingException;
import org.sixstreams.search.PreIndexProcessor;
import org.sixstreams.search.RuntimeSearchException;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.SearchEngine;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchSecurityException;
import org.sixstreams.search.Searcher;
import org.sixstreams.search.Securable;
import org.sixstreams.search.impl.ExprEvaluatorFactory;
import org.sixstreams.search.impl.ExpressionEvaluator;
import org.sixstreams.search.meta.AttributeDefImpl;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.DocumentDefinition;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.PrimaryKey;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ContextFactory;


public class DocumentService
{
   private SearchableObject searchableObject;
   private Object searchPlugin;
   private SearchContext context;

   public DocumentService(SearchableObject so)
   {
      context = ContextFactory.getSearchContext();
      searchableObject = so;
      context.setSearchableObject(searchableObject);
      try
      {
         searchPlugin = searchableObject.getSearchPlugin();
      }
      catch (SearchSecurityException sse)
      {
         throw new RuntimeSearchException("Failed to create search plugin", sse);
      }
   }

   public DocumentService process(IndexableDocument doc)
      throws SearchException
   {
      List<IndexableDocument> docs = new ArrayList<IndexableDocument>();
      docs.add(doc);
      return process(docs);
   }

   public DocumentService process(List<IndexableDocument> docs)
      throws SearchException
   {
      for (IndexableDocument searchDocument: docs)
      {
         evaluateExpression(searchDocument);
      }
      //plugin is called where develeopers can add/delete some documents
      //as a result the list and the data might be differet after this call.
      preIndexProcess(docs);
      secureDocuments(docs);
      return this;
   }

   public void post(List<IndexableDocument> indexableDocs)
      throws IndexingException
   {
      if (indexableDocs.size() == 0)
      {
         //does nothing
         return;
      }
      //all docs must belong to the same searchable object
      SearchableObject so = indexableDocs.get(0).getSearchableObject();
      SearchEngine engine = MetaDataManager.getSearchEngine(so.getSearchEngineInstanceId());
      Indexer indexer = engine.getIndexer();
      try
      {
         for (IndexableDocument indexableDoc: indexableDocs)
         {
            indexer.indexDocument(indexableDoc);
         }
      }
      finally
      {
         indexer.close();
      }
   }

   public void post(IndexableDocument indexableDoc)
      throws IndexingException
   {
      List<IndexableDocument> list = new ArrayList<IndexableDocument>();
      list.add(indexableDoc);
      post(list);
   }
   
   //delete by query

   public void deleteDataObjectsByFilters(List<AttributeFilter> filters)
      throws IndexingException
   {
      SearchEngine engine = MetaDataManager.getSearchEngine(searchableObject.getSearchEngineInstanceId());
      Searcher searcher = engine.getSearcher();
      searcher.deleteObjectsByFilters(searchableObject, filters);
   }

   public void deleteDataObject(Object object)
      throws IndexingException
   {
      if (searchableObject instanceof SearchableDataObject)
      {

         IndexableDocument indexableDoc = ((SearchableDataObject) searchableObject).createIndexableDocument(object);
         deleteDocument(indexableDoc);
      }
   }

   public void deleteDocument(Document doc)
      throws IndexingException
   {
      if (searchableObject instanceof SearchableDataObject)
      {
         List<AttributeFilter> filters = new ArrayList<AttributeFilter>();

         PrimaryKey pk = doc.getPrimaryKey();

         for (Object key: pk.keySet())
         {
            filters.add(new AttributeFilter(key.toString(), null, pk.get(key), Constants.OPERATOR_EQS));
         }
         deleteDataObjectsByFilters(filters);
      }
   }


   public void postDataObjects(List<?> objects)
      throws IndexingException
   {
      if (searchableObject instanceof SearchableDataObject)
      {
         SearchEngine engine = MetaDataManager.getSearchEngine(searchableObject.getSearchEngineInstanceId());
         if (engine == null)
         {
            throw new IndexingException("Search engine not found - " + searchableObject.getSearchEngineInstanceId());
         }
         SearchContext ctx = ContextFactory.getSearchContext();
         ctx.setSearchableObject(searchableObject);
         Indexer indexer = engine.getIndexer();
         try
         {
            List<IndexableDocument> docs = new ArrayList<IndexableDocument>();
            for (Object object: objects)
            {
               docs.add(((SearchableDataObject) searchableObject).createIndexableDocument(object));
            }
            process(docs);
            indexer.indexBatch(docs);
         }
         catch (SearchException e)
         {
            e.printStackTrace();
         }
         finally
         {
            indexer.close();
         }
      }
   }

   public void postDataObject(Object object)
      throws IndexingException
   {
      List<Object> objects = new ArrayList<Object>();
      objects.add(object);
      postDataObjects(objects);
   }

   //convert data without plugin and security
   public IndexedDocument convert(IndexableDocument doc)
   {
      evaluateExpression(doc);
      SearchableObject so = doc.getSearchableObject();
      SearchContext ctx = ContextFactory.getSearchContext();
      ctx.setSearchableObject(so);
      IndexedDocument indexedDocument = MetaDataManager.getSearchEngine(so.getSearchEngineInstanceId()).getSearcher().createIndexedDocument(ctx,
                                                                                                             doc.getAttributeValues());
      indexedDocument.setTitle(doc.getTitle());
      indexedDocument.setContent(doc.getContent());
      indexedDocument.addTags(doc.getTags());
      return indexedDocument;
   }
   //private methods

   public static void evaluateExpression(IndexableDocument searchDocument)
   {
      SearchableObject so = searchDocument.getSearchableObject();
      ExpressionEvaluator evs = ExprEvaluatorFactory.getEvaluator(searchDocument);
      Object value = null;
      String expr = "";
      try
      {
         expr = so.getTitle();
         if (expr != null)
         {
            value = evs.evaluate(expr);

            if (value != null)
            {
               searchDocument.setTitle(value.toString());
            }
         }

         // evaluate and set keywords
         expr = so.getKeywords();
         if (expr != null)
         {
            value = evs.evaluate(expr);

            if (value != null)
            {
               searchDocument.setKeywords(value.toString());
            }
         }

         // evaluate and set body
         expr = so.getContent();
         if (expr != null)
         {
            value = evs.evaluate(expr);

            if (value != null)
            {
               searchDocument.setContent(value.toString());
            }
         }

      }
      catch (Exception e)
      {
         String msg = "Failed to evaluate the expression for " + expr + " of " + so.getName();

         throw new RuntimeSearchException(msg, e);
      }
   }

   private void preIndexProcess(List<IndexableDocument> documents)
   {
      SearchContext ctx = ContextFactory.getSearchContext();
      if (searchPlugin instanceof PreIndexProcessor)
      {
         try
         {
            ((PreIndexProcessor) searchPlugin).preIndexProcess(ctx, documents);
         }
         catch (Throwable t)
         {
            throw new RuntimeSearchException("Failed to execute preIndexProcess for " + searchableObject.getName(), t);
         }
      }
   }

   private void secureDocuments(List<IndexableDocument> documents)
      throws SearchSecurityException
   {
      for (IndexableDocument document: documents)
      {
         secureDocument(document);
         document.removeChildDocs(); // remove no longer needed child docs
      }
   }

   private void secureDocument(IndexableDocument searchDocument)
      throws SearchSecurityException
   {
      if (searchPlugin == null)
      {
         searchPlugin = searchableObject.getSearchPlugin();
      }
      if (searchPlugin instanceof Securable)
      {
         List<String> acl = null;

         for(AttributeDefinition attrDef : searchDocument.getSearchableObject().getDocumentDef().getAttrDefs())
         {
            
            String secAttr = attrDef.getName();

            if (!Constants.ACL_KEY.equals(secAttr))
            {
               if (attrDef.isSecure())
               {
                  try
                  {
                     acl = ((Securable) searchPlugin).getSecureAttrAcl(searchDocument, secAttr);
                  }
                  catch (Throwable t)
                  {
                     throw new SearchSecurityException("Failed to execut getSecureAttrAcl for " +
                                                       searchableObject.getName(), t);
                  }

                  if (acl != null)
                  {
                     searchDocument.setAttribueAcl(secAttr, acl);
                  }
               }
            }
         }

         try
         {
            acl = ((Securable) searchPlugin).getAcl(searchDocument);
         }
         catch (Throwable t)
         {

            throw new SearchSecurityException(t);
         }
         if (acl != null)
         {
            DocumentDefinition docDef = searchDocument.getSearchableObject().getDocumentDef();
            AttributeDefImpl secAttr = (AttributeDefImpl) docDef.getAttributeDef(Constants.ACL_KEY);
            if (secAttr == null) //create on demand
            {
               secAttr = new AttributeDefImpl(Constants.ACL_KEY, String.class.getName());
               secAttr.setSecure(true);
               secAttr.setStored(false);
               searchDocument.getSearchableObject().getDocumentDef().addAttrDef(secAttr);
            }
            searchDocument.setAttribueAcl(secAttr.getName(), acl);
         }
      }
   }
}
