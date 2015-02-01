package org.sixstreams.search.util;

import java.io.UnsupportedEncodingException;

import java.net.URLDecoder;
import java.net.URLEncoder;

import java.text.CharacterIterator;
import java.text.StringCharacterIterator;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.sixstreams.search.data.java.TypeMapper;
import org.sixstreams.search.res.DefaultBundle;

public class EncodeUtil
{
   protected static Logger sLogger = Logger.getLogger(EncodeUtil.class.getName());

   /**
    * URL encode the string in UTF-8
    * @param str - the string to encode. Can be null.
    * @return encoded string
    */
   public static String urlEncode(String str)
   {
      str = (str == null)? "": str;
      try
      {
         str = URLEncoder.encode(str, "UTF-8");
      }
      catch (UnsupportedEncodingException e)
      {
         // should never happen
         sLogger.log(Level.SEVERE, DefaultBundle.getResource(DefaultBundle.ERROR_ENCODEUTIL_URL_ENCODE), e);
      }
      return str;
   }

   /**
    * URL decode the string in UTF-8
    * @param str - the string to decode. Can be null.
    * @return encoded string
    */
   public static String urlDecode(String str)
   {
      str = (str == null)? "": str;
      try
      {
         str = URLDecoder.decode(str, "UTF-8");
      }
      catch (UnsupportedEncodingException e)
      {
         // should never happen
         sLogger.log(Level.SEVERE, DefaultBundle.getResource(DefaultBundle.ERROR_ENCODEUTIL_URL_DECODE), e);
      }
      return str;
   }

   /**
    * Url encode the str 2 times.
    * @param str
    * @return
    */
   public static String urlEncode2(String str)
   {
      str = urlEncode(str);
      str = urlEncode(str);
      return str;
   }

   /**
    * Encode characters in a url to prevent cross-site scripting attacks.
    * This means encode the special characters ('<', '>', '"', etc),
    * but do not encode chars that are part of representations of chars that are
    * already encoded by the browser (like '%') or other chars like '/'.
    *
    * @param str
    * @return url encoded string.
    */
   public static String urlEncodeForXSS(String str)
   {
      final StringBuilder result = new StringBuilder();
      final StringCharacterIterator iterator = new StringCharacterIterator(str);
      char character = iterator.current();
      while (character != CharacterIterator.DONE)
      {
         if (character == '<' || character == '>' || character == '\'' || character == '"')
         {
            result.append(urlEncode(new String(new char[]
                        { character })));
         }
         else
         {
            //add it to the result as is
            result.append(character);
         }
         character = iterator.next();
      }
      return result.toString();
   }

   /**
    * Encapsulate a string in a CDATA section.
    * @param str - the string to wrap in a cdata section
    * @return CDATA section
    */
   public static String cdataSection(String str)
   {
      if (str == null)
      {
         return "";
      }
      if (str.trim().isEmpty())
      {
         return str;
      }
      return CDATA_HEADER + cdataEncode(str) + CDATA_FOOTER;
   }

   /**
    * Encode any ']]>' strings inside a CDATA section.
    * @param cdataStr - the string inside a CDATA section to encode.
    * @return encoded content of CDATA
    */
   public static String cdataEncode(String cdataStr)
   {
      if (cdataStr == null)
      {
         return "";
      }

      if (cdataStr.indexOf(CDATA_NEED_ESCAPE_STR) != -1)
      {
         Matcher m = cdataPat.matcher(cdataStr);
         cdataStr = m.replaceAll(CDATA_ESCAPED_STR);
      }

      return cdataStr;
   }

   private static final String CDATA_NEED_ESCAPE_STR = "]]>"; // look for ']]>'
   private static Pattern cdataPat = Pattern.compile("\\]\\]>"); // regexp of ']]>'
   private static final String CDATA_ESCAPED_STR = "]]]]><![CDATA[>"; // replace with this string

   private static final String CDATA_HEADER = "<![CDATA[";
   private static final String CDATA_FOOTER = "]]>";

   /**
    * Encode the special characters for text appearing as xml data, between tags.
    * @return encoded content
    */
   public static String xmlDataEncode(Object xmlDataStr)
   {
      if (xmlDataStr == null)
      {
         return "";
      }

      final StringBuilder result = new StringBuilder();

      final StringCharacterIterator iterator = new StringCharacterIterator(TypeMapper.toString(xmlDataStr));
      char character = iterator.current();
      while (character != CharacterIterator.DONE)
      {
         if (character == '<')
         {
            result.append("&lt;");
         }
         else if (character == '>')
         {
            result.append("&gt;");
         }
         else if (character == '\"')
         {
            result.append("&quot;");
         }
         else if (character == '\'')
         {
            result.append("&#039;");
         }
         else if (character == '&')
         {
            result.append("&amp;");
         }
         else
         {
            //the char is not a special one
            //add it to the result as is
            result.append(character);
         }
         character = iterator.next();
      }
      return result.toString().trim();
   }

   /**
    * Encode '\' which is interpreted by SES as an escape char,
    * and the '/' char which is interpreted by SES as a delimiter.
    *
    * Example: the string containing 3 chars r"\a/" =>
    *          will be encoded as the string containing 5 chars r"\\a\/".
    * @param attrData
    * @return String - encoded facet data.
    */
   public static String facetValueEncode(String attrData)
   {
      // replace "\" with "\\"
      if (attrData.indexOf('\\') != -1)
      {
         Matcher matcher = singleBackSlashPat.matcher(attrData);
         attrData = matcher.replaceAll(REPLACEMENT_STR_SES_BACK_SLASH); // escape r"\" as r"\\"
      }

      // replace "/" with "\/"
      if (attrData.indexOf('/') != -1)
      {
         Matcher matcher = singleForwardSlashPat.matcher(attrData);
         attrData = matcher.replaceAll(REPLACEMENT_STR_SES_FORWARD_SLASH); // escape '/' as r"\/"
      }

      return attrData;
   }

   private static final String BACKSLASH = "\\";
   private static final String FORWARDSLASH = "/";
   private static final String ESCAPED_BACKSLASH = BACKSLASH + BACKSLASH;
   private static final String ESCAPED_FORWARDSLASH = BACKSLASH + FORWARDSLASH;

   private static Pattern singleBackSlashPat =
      Pattern.compile(ESCAPED_BACKSLASH); // reg exp matching 1 char string '\\'
   private static Pattern singleForwardSlashPat =
      Pattern.compile(ESCAPED_FORWARDSLASH); // reg exp matching 1 char string '/'

   // backslashes in regex replacement strings escape the next character.
   private static final String REPLACEMENT_STR_SES_BACK_SLASH =
      ESCAPED_BACKSLASH + ESCAPED_BACKSLASH; // so this means replace with 2 backslashes.
   private static final String REPLACEMENT_STR_SES_FORWARD_SLASH =
      ESCAPED_BACKSLASH + ESCAPED_FORWARDSLASH; // this means replace with a backslash followed by forwardslash.

}
