package org.sixstreams.search.data.java;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.sixstreams.Constants;
import org.sixstreams.search.Attachment;
import org.sixstreams.search.Document;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.meta.AttributeDefImpl;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.PrimaryKey;
import org.sixstreams.search.util.ContextFactory;
import org.sixstreams.search.util.EncodeUtil;


public class XMLWriter
{
   private Writer mWriter;

   public XMLWriter()
   {
      mWriter = new StringWriter();
   }

   public String getString()
      throws IOException
   {
      this.close();
      return mWriter.toString();
   }

   public XMLWriter(Writer writer)
   {
      mWriter = writer;
   }

   /**
    * Called to write one IndexableDocument.  Will be called by CrawlableFactory.start().
    * @param document
    */
   public void write(IndexableDocument document)
   {
      mSearchContext = ContextFactory.getSearchContext();
      mBatch.add(document);
      if (mBatch.size() >= mBatchSize)
      {
         try
         {
            flush();
         }
         catch (IOException e)
         {
            throw new RuntimeException(e);
         }
      }
   }

   private void write(String value)
      throws IOException
   {
      mWriter.write(value);
   }

   /**
    * Flushes IndexableDocument batch, and calls super.flush()
    * This method is not thread safe (batch could be written multiple times).
    */
   public void flush()
      throws IOException
   {
      if (!mHeaderWritten)
      {
         mWriter.write(getHeaderXML().toString());
         mHeaderWritten = true;
      }

      if (mBatch.size() > 0)
      {
         StringBuffer stringBuffer = serializeDocuments(mBatch);
         write(stringBuffer.toString());
      }
      mBatch.clear();
      mWriter.flush();
   }

   /**
    * Closes the feed.
    * @throws IOException if failed to write to the stream.
    */
   public void close()
      throws IOException
   {
      flush();
      write(getFooterXML().toString());
   }

   /* --- Package level methods --- */

   StringBuffer getHeaderXML()
   {
      StringBuffer xmlBuf = new StringBuffer(XML);
      String url = (String) mSearchContext.getAttribute(FEED_URL);
      xmlBuf.append(RSS_B).append(CHANNEL_B).append(addTag(ATTR_TITLE, CHANNEL_TITLE)).append(addTag(ATTR_LINK,
                                                                                                     url + DATA_FEED_CTX,
                                                                                                     true)).append(addTag(DESCRIPTION,
                                                                                                                          CHANNEL_DESC)).append(addTag(LAST_BUILD_DATE, TypeMapper.toString(new Date()))).append(CHANNEL_DESC_B).append(addTag(FEED_TYPE,
                                                                                                                                                                                                                              DATA_FEED)).append(CHANNEL_DESC_E);
      return xmlBuf;
   }

   StringBuffer getFooterXML()
   {
      StringBuffer footerXML = new StringBuffer(CHANNEL_E).append(RSS_E);
      return footerXML;
   }

   StringBuffer serializeDocuments(List<Document> batch)
   {
      StringBuffer xmlBuf = new StringBuffer();
      Iterator<Document> iter = batch.iterator();
      while (iter.hasNext())
      {
         xmlBuf.append(serializeDocument(iter.next()));
      }
      batch.clear();
      return xmlBuf;
   }

   private StringBuffer addTag(String tagName, Object tagValue)
   {
      return addTag(tagName, tagValue, false);
   }

   private StringBuffer addTag(String tagName, Object tagValue, boolean cdata)
   {
      if (tagValue == null || tagValue.toString().trim().length() == 0)
      {
         return new StringBuffer();
      }
      if (cdata)
      {
         return new StringBuffer(LS).append(tagName).append(LG).append(CDATA_B).append(EncodeUtil.cdataEncode(tagValue.toString())).append(CDATA_E).append(LS_E).append(tagName).append(LG);
      }
      else
      {
         return new StringBuffer(LS).append(tagName).append(LG).append(tagValue).append(LS_E).append(tagName).append(LG);
      }
   }

   private StringBuffer serializeDocument(Object document)
   {
      IndexableDocument doc = (IndexableDocument) document;
      StringBuffer xmlBuf = new StringBuffer();
      Collection<AttributeDefinition> fields = doc.getSearchableObject().getDocumentDef().getAttrDefs();
      String url = (String) mSearchContext.getAttribute(FEED_URL);
      String lastModified = null;

      xmlBuf.append(ITEM_B);

      xmlBuf.append(addTag(ATTR_TITLE, doc.getTitle(), true));

      if (DELETE.equals(doc.getActionType()))
      {
         xmlBuf.append(DELETE_ITEM);
      }
      else
      {
         xmlBuf.append(INSERT_ITEM);

         /* documentMetaData */
         xmlBuf.append(DOC_META_DATA_B);
         xmlBuf.append(addTag(ATTR_ACCESSURL, doc.getAccessURL(), true));
         xmlBuf.append(addTag(ATTR_KEYWORDS, doc.getKeywords(), true));

         String language = doc.getLanguage();
         if (language == null || language.length() == 0)
         {
            language = Locale.ENGLISH.getLanguage();
         }
         xmlBuf.append(addTag(LANAGUAGE, language, false));

         StringBuffer securityAttrs = new StringBuffer();
         for (Iterator<AttributeDefinition> iter = fields.iterator(); iter.hasNext(); )
         {
            AttributeDefImpl field = (AttributeDefImpl) iter.next();
            String name = field.getName();
            Object fieldValue = doc.getAttrValue(name);

            if (field.isSecure())
            {
               List<String> securityAttrArray = doc.getAttributeAcl(name);
               if (securityAttrArray != null)
               {
                  for (String ace: securityAttrArray)
                  {
                     securityAttrs.append(SECURE_ATTR_B);
                     securityAttrs.append(EncodeUtil.xmlDataEncode(name));
                     securityAttrs.append(Single_QUOTE).append(LG);
                     securityAttrs.append(ace);
                     securityAttrs.append(SECURE_ATTR_E);
                  }
               }
            }

            // ensure that facet fields always have some value.
            if (field.isFacetAttr())
            {
               boolean bUseDefault = false;

               if (fieldValue == null)
               {
                  bUseDefault = true;
               }
               else if (fieldValue instanceof Object[])
               {
                  Object[] array = (Object[]) fieldValue;
                  int i;
                  for (i = 0; i < array.length; i++)
                  {
                     if (array[i] != null)
                     {
                        break;
                     }
                  }
                  if (i == array.length)
                  {
                     // no non-nulls found
                     bUseDefault = true;
                  }
               }
               else if (fieldValue instanceof ArrayList)
               {
                  ArrayList<?> array = (ArrayList<?>) fieldValue;
                  int i;
                  for (i = 0; i < array.size(); i++)
                  {
                     if (array.get(i) != null)
                     {
                        break;
                     }
                  }
                  if (i == array.size())
                  {
                     // no non-nulls found
                     bUseDefault = true;
                  }
               }

               if (bUseDefault)
               {
                  fieldValue = FACET_FIELD_DEFAULT_VALUE;
               }
            }

            if (field.isStored() && fieldValue != null)
            {
               // create the value array
               Object[] valueArray = null;
               if (fieldValue instanceof Object[])
               {
                  valueArray = (Object[]) fieldValue;
               }
               else if (fieldValue instanceof ArrayList)
               {
                  ArrayList<?> array = (ArrayList<?>) fieldValue;
                  valueArray = array.toArray(new Object[0]);
               }
               else
               {
                  valueArray = new Object[]
                        { fieldValue };
               }

               // convert to string format
               for (int i = 0; i < valueArray.length; i++)
               {
                  if (valueArray[i] instanceof Date)
                  {
                     valueArray[i] = TypeMapper.toString((Date) valueArray[i]);
                  }
                  else
                  {
                     valueArray[i] = valueArray[i].toString();
                  }

                  // if facet field, perform special encoding.
                  if (field.isFacetAttr())
                  {
                     valueArray[i] = EncodeUtil.facetValueEncode(valueArray[i].toString());
                  }
               }

               if (name.equals(Constants.LAST_MODIFIED_DATE))
               {
                  if (valueArray != null && valueArray.length > 0)
                  {
                     lastModified = EncodeUtil.xmlDataEncode(valueArray[0].toString());
                  }
               }

               // output to ses
               else
               {
                  for (int i = 0; i < valueArray.length; i++)
                  {
                     //LastModifiedDate should not be sent as doc attribute
                     xmlBuf.append(DOC_ATTR_B);
                     xmlBuf.append(EncodeUtil.xmlDataEncode(name));
                     xmlBuf.append(Single_QUOTE);
                     xmlBuf.append(TYPE_EQ).append(TypeMapper.convert(field.getDataType()));
                     xmlBuf.append(Single_QUOTE);
                     xmlBuf.append(LG);
                     xmlBuf.append(EncodeUtil.xmlDataEncode(valueArray[i].toString()));
                     xmlBuf.append(DOC_ATTR_E);
                  }
               }
            }
         }

         xmlBuf.append(DOC_ATTR_B);
         xmlBuf.append(Constants.SO_NAME);
         xmlBuf.append(STRING_TYPE);
         xmlBuf.append(EncodeUtil.xmlDataEncode(doc.getSearchableObject().getName()));
         xmlBuf.append(DOC_ATTR_E);


         String actionTitle = (String) doc.getAttrValue(Constants.ACTION_TITLE);
         if (actionTitle == null)
         {
            xmlBuf.append(DOC_ATTR_B);
            xmlBuf.append(Constants.ACTION_TITLE);
            xmlBuf.append(STRING_TYPE);
            xmlBuf.append(CDATA_B).append(EncodeUtil.cdataEncode(actionTitle)).append(CDATA_E);
            xmlBuf.append(DOC_ATTR_E);
         }

         StringBuffer tags = new StringBuffer();
         for (String tag: doc.getTags())
         {
            tags.append(tag).append(" ");
         }

         xmlBuf.append(DOC_ATTR_B);
         xmlBuf.append(STRING_TYPE);
         xmlBuf.append(CDATA_B).append(EncodeUtil.cdataEncode(tags.toString())).append(CDATA_E);
         xmlBuf.append(DOC_ATTR_E);

         //need to add lastModifiedDate as separate element to be written to SES base table
         //SES will not return LASTMOFIFIEDDATE attribute as part of ResultsElement customer attribute
         //list because the name conflicts with
         if (lastModified != null)
         {
            xmlBuf.append(addTag(ATTR_LAST_MODIFIED, lastModified));
         }
         xmlBuf.append(DOC_META_DATA_E);

         /* documentAcl.  Insert ACL list.  Seperate from secure fields */
         xmlBuf.append(DOC_ACL_B);
         xmlBuf.append(securityAttrs);
         xmlBuf.append(DOC_ACL_E);

         /* documentInfo */
         xmlBuf.append(DOC_INFO_B);
         xmlBuf.append(addTag(STATUS, STATUS_OK_FOR_INDEX));
         xmlBuf.append(DOC_INFO_E);

         String content = doc.getContent();
         List<Attachment> attachments = doc.getAttachments();
         if (content != null || (attachments != null && attachments.size() > 0))
         {
            xmlBuf.append(DOC_CONTENT_B);

            //content
            if (content != null && content.trim().length() > 0)
            {
               xmlBuf.append(CONTENT_B).append(CDATA_B).append(EncodeUtil.cdataEncode(content)).append(CDATA_E).append(CONTENT_E);
            }

            for (Iterator<Attachment> iter = attachments.iterator(); iter.hasNext(); )
            {
               Attachment attachment = (Attachment) iter.next();
               Map<?, ?> parameters = attachment.getParameters();

               xmlBuf.append(CONTENT_LINK_B).append(CDATA_B);

               StringBuffer xmlBuf2 = new StringBuffer();
               xmlBuf2.append(url + ATTACHMENT_CTX);

               xmlBuf2.append(Attachment.ATTACHMENT_CLASS).append("=").append(attachment.getClass().getName()).append(AMP);

               Iterator<?> iter2 = parameters.keySet().iterator();
               while (iter2.hasNext())
               {
                  String key = (String) iter2.next();
                  String value = (String) parameters.get(key);
                  xmlBuf2.append(urlEncode(key)).append(EQ).append(urlEncode(value)).append(AMP);
               }

               PrimaryKey keys = attachment.getPrimaryKey();
               iter2 = keys.keySet().iterator();
               int i = 0;
               xmlBuf2.append(Attachment.KEY_COUNT).append(EQ).append(keys.size()).append(AMP);
               while (iter2.hasNext())
               {
                  String key = (String) iter2.next();
                  Object value = keys.get(key);
                  xmlBuf2.append(Attachment.KEY_NAME_PREFIX).append(i).append(EQ).append(urlEncode(key)).append(AMP);
                  xmlBuf2.append(Attachment.KEY_VALUE_PREFIX).append(i).append(EQ).append(urlEncode(value == null? "":
                                                                                                    value.toString())).append(AMP);
                  i++;
               }

               xmlBuf.append(EncodeUtil.cdataEncode(xmlBuf2.toString()));
               xmlBuf.append(CDATA_E).append(CONTENT_LINK_E);
            }
            xmlBuf.append(DOC_CONTENT_E);
         }
      }
      xmlBuf.append(ITEM_DESC_E);
      xmlBuf.append(ITEM_E);
      return xmlBuf;
   }

   protected String urlEncode(String str)
   {
      return EncodeUtil.urlEncode(str);
   }

   //these fields are used by SESControlFeedWriter
   protected int mBatchSize = DEFAULT_BATCH_SIZE;
   protected List<Document> mBatch = new ArrayList<Document>();
   protected SearchContext mSearchContext = null;
   protected boolean mHeaderWritten = false;

   //static constants
   private static final int DEFAULT_BATCH_SIZE = 100;
   private static final String DELETE_ITEM =
      "<itemDesc xmlns=\"http://xmlns.sixstreams.org/orarss\" operation=\"delete\" >";
   private static final String INSERT_ITEM =
      "<itemDesc xmlns=\"http://xmlns.sixstreams.org/orarss\" operation=\"insert\" >";

   private static final String LANAGUAGE = "language", DOC_ATTR_B = "<docAttr name=\"", DOC_ATTR_E =
      "</docAttr>", SECURE_ATTR_B = "<securityAttr name=\"", SECURE_ATTR_E = "</securityAttr>", Single_QUOTE =
      "\"", LG = ">", LS = "<", LS_E = "</", TYPE_EQ = " type=\"", STRING_TYPE = "\" type=\"string\">", ITEM_B =
      "<item>", ITEM_E = "</item>", ITEM_DESC_E = "</itemDesc>", DOC_META_DATA_B =
      "<documentMetadata>", DOC_META_DATA_E = "</documentMetadata>";
   private static final String ATTR_LINK = "link", ATTR_TITLE = "title", ATTR_ACCESSURL = "accessURL", ATTR_KEYWORDS =
      "keywords", ATTR_LAST_MODIFIED = "lastModifiedDate", DELETE = "DELETE";

   private static final String DOC_ACL_B = "<documentAcl>", DOC_ACL_E = "</documentAcl>", DOC_INFO_B =
      "<documentInfo>", DOC_INFO_E = "</documentInfo>", DOC_CONTENT_B = "<documentContent>", DOC_CONTENT_E =
      "</documentContent>", CDATA_E = "]]>", CDATA_B = "<![CDATA[", CONTENT_B =
      "<content contentType=\"text/plain\">", CONTENT_E = "</content>", CONTENT_LINK_B =
      "<contentLink>", CONTENT_LINK_E = "</contentLink>", STATUS = "status", STATUS_OK_FOR_INDEX =
      "STATUS_OK_FOR_INDEX", AMP = "&", EQ = "=";

   static final String XML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
   static final String FEED_URL = "FEED_URL", ATTACHMENT_CTX = "/Attachment?";
   static final String RSS_B = "<rss xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"2.0\">", RSS_E =
      "</rss>";
   static final String CHANNEL_B = "<channel>", CHANNEL_E = "</channel>";
   static final String CHANNEL_TITLE = "RSS for Oracle Applications Search", CHANNEL_DESC =
      "RSS for Oracle Applications Search", DATA_FEED_CTX = "/DataFeed";

   static final String CHANNEL_DESC_B = "<channelDesc xmlns=\"http://xmlns.sixstreams.org/orarss\" >", CHANNEL_DESC_E =
      "</channelDesc>";
   static final String SOURCE_NAME = "sourceName";
   static final String FEED_TYPE = "feedType", DATA_FEED = "DATAFEED";
   static final String LAST_BUILD_DATE = "lastBuildDate";
   static final String DESCRIPTION = "description";
   public static final String FACET_FIELD_DEFAULT_VALUE = "DEFAULT_VALUE_123Z";
}
