package org.sixstreams.search.crawl.crawler;

import org.sixstreams.search.meta.SearchableObject;

public class SearchableObjectImpl
   extends SearchableObject
{

   private String objectName;

   public SearchableObjectImpl()
   {
      setDocumentDef(new DocumentDefinitionImpl(getClass().getName()));
   }

   public SearchableObjectImpl(String name)
   {
      objectName = name;
      setDocumentDef(new DocumentDefinitionImpl(getClass().getName()));
   }

   public String getName()
   {
      return objectName == null? getClass().getName(): objectName;
   }
}
