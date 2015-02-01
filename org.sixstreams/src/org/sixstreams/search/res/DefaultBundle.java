package org.sixstreams.search.res;

import java.util.Enumeration;
import java.util.ResourceBundle;
import java.util.Vector;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.util.ContextFactory;


public class DefaultBundle
   extends ResourceBundle
{
   static DefaultBundle bundle = new DefaultBundle();

   private DefaultBundle()
   {
      super();
   }

   public static final String SEARCHGROUP_LOAD_SO_FAILED =
      "SEARCHGROUP_LOAD_SO_FAILED", FEDERATION_UTIL_STACKTRACE_ERROR =
      "FEDERATION_UTIL_STACKTRACE_ERROR", ERROR_SEARCH_LOAD_PROPERTIES =
      "ERROR_SEARCH_LOAD_PROPERTIES", FEDERATION_ACTION_RESOLVE_ERROR =
      "FEDERATION_ACTION_RESOLVE_ERROR", ERROR_ADF_SEARCH_CONTEXT_RELEASE_CONNECTION =
      "ERROR_ADF_SEARCH_CONTEXT_RELEASE_CONNECTION", INDEXEDDOC_NUMBER_FORMAT_ERROR =
      "INDEXEDDOC_NUMBER_FORMAT_ERROR", SAVED_SEARCH_DESERIALIZE_ERROR =
      "SAVED_SEARCH_DESERIALIZE_ERROR", INDEXEDDOC_DATE_FORMAT_ERROR =
      "INDEXEDDOC_DATE_FORMAT_ERROR", SESSION_LOGOUT_FAILED_SEVERE =
      "SESSION_LOGOUT_FAILED_SEVERE", ERROR_ENCODEUTIL_URL_ENCODE =
      "ERROR_ENCODEUTIL_URL_ENCODE", ERROR_ENCODEUTIL_URL_DECODE =
      "ERROR_ENCODEUTIL_URL_DECODE", SAVED_SEARCH_SERIALIZE_ERROR =
      "SAVED_SEARCH_SERIALIZE_ERROR", SAVED_SEARCH_MISSING_CLASS_ERROR =
      "SAVED_SEARCH_MISSING_CLASS_ERROR", WARNING_ABSTRACT_DOCUMENT_FAILED_ENCODE_PRIMARY_KEY =
      "WARNING_ABSTRACT_DOCUMENT_FAILED_ENCODE_PRIMARY_KEY", WARNING_ACTION_URL_RESOLVER_EVALUATE_EXPRESSION =
      "WARNING_ACTION_URL_RESOLVER_EVALUATE_EXPRESSION", QUERY_MISSING_SG_ERROR =
      "QUERY_MISSING_SG_ERROR", QUERY_MISSING_QUERY_STRING_ERROR = "QUERY_MISSING_QUERY_STRING_ERROR";

   public static String getResource(String key, String[] params)
   {
      return bundle.getResource(key);
   }

   public static String getResource(String key)
   {
      return bundle.handleGetObject(key).toString();
   }

   public static String getResource(Object object, String key)
   {
      SearchContext ctx = ContextFactory.getSearchContext();
      return key;
   }

   public Enumeration<String> getKeys()
   {
      Vector<String> vector = new Vector<String>();
      return vector.elements();
   }

   protected Object handleGetObject(String key)
   {
      return getResource(this, key);
   }
}
