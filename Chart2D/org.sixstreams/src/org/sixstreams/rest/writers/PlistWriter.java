package org.sixstreams.rest.writers;

import org.sixstreams.search.AttributeValue;
import org.sixstreams.search.HitsMetaData;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.meta.SearchableGroup;

public class PlistWriter
   extends XMLWriter
{
   public String getContentType()
   {
      return "text/xml";
   }

   private StringBuffer doc2String(IndexedDocument doc)
   {
      StringBuffer buffer = new StringBuffer();
      buffer.append("<dict>");
      buffer.append("<key>title</key><string>").append(toCDATASection(doc.getTitle())).append("</string>");
      buffer.append("<key>content</key><string>").append(toCDATASection(doc.getContent())).append("</string>");
      buffer.append("<key>attributes</key><array>");
      for (AttributeValue value: doc.getAttributeValues())
      {
         if (this.isAttributeRendered(value.getName()))
         {
            buffer.append("<dict><key>").append(toCDATASection(value.getName())).append("</key><string>").append(toCDATASection("" +
                                                                                                                                value.getValue())).append("</string></dict>");
         }
      }
      buffer.append("</array>");
      buffer.append("</dict>");
      return buffer;
   }

   private StringBuffer group2String(SearchableGroup group)
   {
      StringBuffer buffer = new StringBuffer();
      buffer.append("<dict>");
      buffer.append("<key>engineInstance</key><string>").append(group.getEngineInstanceId()).append("</string>");
      buffer.append("<key>name</key><string>").append(toCDATASection(group.getName())).append("</string>");
      buffer.append("<key>displayName</key><string>").append(toCDATASection(group.getDisplayName())).append("</string>");
      buffer.append("</dict>");
      return buffer;
   }

   public StringBuffer toString(Object object)
   {
      StringBuffer buffer = new StringBuffer();
      buffer.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
      buffer.append("<plist>");
      if (object instanceof SearchHits)
      {
         SearchHits hits = (SearchHits) object;
         HitsMetaData hmd = hits.getHitsMetaData();
         buffer.append("<dict>");
         buffer.append("<key>NoOfHits</key><string>").append(hmd.getHits()).append("</string>");
         buffer.append("<key>TimeSpent</key><string>").append(hmd.getTimeSpent()).append("</string>");

         buffer.append("<key>Hits</key><array>");
         for (int i = 0; i < hits.getCount(); i++)
         {
            IndexedDocument doc = hits.getDocument(i);
            buffer.append(doc2String(doc));
         }
         buffer.append("</array>");
         buffer.append("</dict>");
      }
      else if (object instanceof SearchableGroup[])
      {
         SearchableGroup[] groups = (SearchableGroup[]) object;
         buffer.append("<array>");
         for (SearchableGroup group: groups)
         {
            buffer.append(group2String(group));
         }
         buffer.append("</array>");
      }
      else if (object instanceof Throwable)
      {
         buffer.append(exceptionToString((Throwable) object));
      }
      buffer.append("</plist>");
      return buffer;
   }

   public StringBuffer exceptionToString(Throwable sgs)
   {
      StringBuffer result = new StringBuffer();
      result.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
      result.append("<plist><item><name>Error</name><string>").append(sgs.getLocalizedMessage()).append("</string></item></plist>");
      return result;
   }

}
