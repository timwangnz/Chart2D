package org.sixstreams.search.crawl.crawler;


import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.meta.AbstractDocumentDefinition;

public class DocumentDefinitionImpl
   extends AbstractDocumentDefinition
{
   public DocumentDefinitionImpl(String name)
   {
      super(name);
   }

   public String getFullName()
   {
      return getSearchableObject().getName();
   }

   public String getSelectStatement(IndexableDocument parentDoc)
   {
      return null;
   }
   

}
