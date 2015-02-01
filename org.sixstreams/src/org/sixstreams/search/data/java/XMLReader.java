package org.sixstreams.search.data.java;

import java.io.Reader;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.crawl.crawler.IndexableDocumentImpl;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.XMLTable;
import org.sixstreams.search.util.XMLUtil;

public class XMLReader
{
 

   public XMLReader(Reader reader)
   {
     
   }

   public XMLReader()
   {

   }

   public List<IndexableDocument> read(String xml)
   {
      XMLTable xmlTable = XMLUtil.toHashMap(xml);

      List<IndexableDocument> docs = new ArrayList<IndexableDocument>();
      List<?> items = xmlTable.getList("rss.channel.item");
      if (items == null)
      {
         throw new UnsupportedOperationException("XML can not be handled");
      }

      for (Object item: items)
      {
         docs.add(toDoc((XMLTable) item));
      }
      return docs;
   }

   private IndexableDocument toDoc(XMLTable xmlTable)
   {
      String url = xmlTable.get("link.textValue").toString();

      String objectName = url.substring("http://org.sixstreams.com/search/".length(), url.indexOf("?"));

      String engineInst = "-1";

      SearchableObject object = MetaDataManager.getSearchableObject(Long.valueOf(engineInst), objectName);
      IndexableDocumentImpl indexableDoc = new IndexableDocumentImpl(object);

      indexableDoc.setTitle(xmlTable.get("title.textValue").toString());
      indexableDoc.setKeywords("" + xmlTable.get("itemDesc.documentMetadata.keywords.textValue"));
      indexableDoc.overrideAccessURL("" + xmlTable.get("itemDesc.documentMetadata.accessUrl.textValue"));

      indexableDoc.setContent(xmlTable.get("itemDesc.documentContent.content.textValue").toString());
      String operation = xmlTable.get("itemDesc.operation").toString();
      System.err.println("Operation " + operation);

      String language = xmlTable.get("itemDesc.documentMetadata.language.textValue").toString();
      if (language != null && language.length() > 0)
      {
         indexableDoc.setLanguage(language);
      }
      List<?> docsAttrs = xmlTable.getList("itemDesc.documentMetadata.docAttr");

      for (Object item: docsAttrs)
      {
         assignAttr(indexableDoc, (XMLTable) item);
      }
      return indexableDoc;
   }

   private void assignAttr(IndexableDocumentImpl indexableDoc, XMLTable xmlTable)
   {
      String name = xmlTable.get("name").toString();
      String type = xmlTable.get("type").toString();
      Object content = xmlTable.get("textValue");

      if (content != null)
      {
         Object value = TypeMapper.toObject(type, content.toString());
         indexableDoc.setAttrValue(name, value);
      }
   }

}
