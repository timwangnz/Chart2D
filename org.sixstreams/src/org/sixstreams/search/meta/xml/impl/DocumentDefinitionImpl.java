package org.sixstreams.search.meta.xml.impl;

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
      return this.getName();
   }

   public String getSelectStatement(IndexableDocument indexableDocument)
   {
      return null;
   }
}
