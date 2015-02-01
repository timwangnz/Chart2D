package org.sixstreams.search.util;


import java.io.File;
import java.io.StringReader;

import java.net.URL;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;


public class XMLUtil
   extends DefaultHandler
{
   public static final String TEXT_VALUE_KEY = "textValue";

   private XMLUtil(String xml)
   {
      this.mXmlSource = xml;
   }

   private XMLUtil(java.io.File xmlFile)
   {
      this.mXmlSource = xmlFile;
   }

   private XMLUtil(URL url)
   {
      this.mXmlSource = url;
   }

   public static XMLTable toHashMap(String xml)
   {
      return new XMLUtil(xml).parse();
   }

   public static XMLTable toHashMap(java.io.File xmlFile)
   {
      return new XMLUtil(xmlFile).parse();
   }

   public static XMLTable toHashMap(URL url)
   {
      return new XMLUtil(url).parse();
   }

   public void startDocument()
      throws SAXException
   {

   }

   public void endDocument()
      throws SAXException
   {

   }


   public void endElement(String uri, String localName, String qName)
      throws SAXException
   {
      mCurrentTable = mParentTable;
      mParentTable = mParentTable.getParent();
   }

   public void startElement(String uri, String localName, String qName, Attributes attributes)
      throws SAXException
   {
      if (mCurrentTable != null)
      {
         mParentTable = mCurrentTable;
      }
      String name = localName.length() == 0? qName: localName;
      mCurrentTable = new XMLTable(mParentTable);
      mParentTable.add(name, mCurrentTable);

      if (attributes != null)
      {
         for (int i = 0; i < attributes.getLength(); i++)
         {
            name = attributes.getLocalName(i);
            name = name.length() == 0? attributes.getQName(i): name;
            mCurrentTable.add(name, attributes.getValue(i));
         }
      }
   }

   public void characters(char[] buf, int offset, int len)
      throws SAXException
   {
      String s = new String(buf, offset, len);

      if (s.length() > 1)
      {
         mCurrentTable.add(TEXT_VALUE_KEY, s);
      }
   }

   private XMLTable parse()
   {
      // Use the default (non-validating) parser
      SAXParserFactory factory = SAXParserFactory.newInstance();
      try
      {
         SAXParser saxParser = factory.newSAXParser();
         if (mXmlSource instanceof String)
         {
            saxParser.parse(new InputSource(new StringReader((String) mXmlSource)), this);
         }
         else if (mXmlSource instanceof File)
         {
            saxParser.parse((File) mXmlSource, this);
         }
         else if (mXmlSource instanceof URL)
         {
            URL url = (URL) mXmlSource;
            saxParser.parse(url.openStream(), this);
         }
         return mRoot;
      }
      catch (Throwable t)
      {
         System.err.println("Failed to parse " + mXmlSource);
         t.printStackTrace();
      }
      return mRoot;
   }

   private XMLTable mRoot = new XMLTable(null);
   private XMLTable mCurrentTable = null;
   private XMLTable mParentTable = mRoot;
   private Object mXmlSource;
}
