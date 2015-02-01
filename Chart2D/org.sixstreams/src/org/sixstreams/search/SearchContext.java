package org.sixstreams.search;

import java.io.Writer;
import java.util.Map;

import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.Cryptor;
import org.sixstreams.social.Person;


/**
 * <code>SearchContext</code> is a runtime container for contextual information
 * for applications search. It contains search related meta information.
 * <p>
 * It also holds a reference to an external context that might be useful for
 * the purpose of search as well as security etc.
 *
 * <p>For example, when used for searching, it holds
 * a reference to AppsWebContext and can be obtained by getAppsContext.
 *<p>
 * This context is passed to most applications plug-in code where custom
 * implemenation can obtain runtime context information.
 */
public interface SearchContext
{
	/**
	 * Returns application id
	 * @return application id
	 */
	String getAppId();
	void setAppId(String id);
	/**
	 * Return application key
	 * @return
	 */
	void setAppKey(String key);
	String getAppKey();
	
	Cryptor getCryptor();

   /**
    * Returns a hashed object;
    */
   Object getAttribute(Object key);

   /**
    * Sets a hash value for the given key.
    * @param key hash key.
    * @param value hash value.
    */
   void setAttribute(Object key, Object value);

   /**
    * Returns a writer to write information to external systems.
    * This writer could be used to write to rss feed to search engine.
    *
    */
   Writer getWriter();

   /**
    * Assigns a writer to this context. It is upto the host application
    * determine how to use the writer. For example, the data
    * service uses this writer to push Rss feed to search engine.
    *
    * @param writer
    */
   void setWriter(Writer writer);

   /**
    * Returns the searchable object associated with this context.
    */
   SearchableObject getSearchableObject();

   /**
    * Associates a searhable object with this context.
    *
    * <p>Every context can only be associated with one searchable
    * object at a time.
    *
    * @param searchableObject to be associated with this context.
    */
   void setSearchableObject(SearchableObject searchableObject);


   /**
    * Releases the context, and clean up resources used by this context.
    * <br>Once released, this context become unusable.
    */
   void release();


   /**
    * Returns user name of the user bound to this context.
    * @return user name;
    */
   String getUserName();

   /**
    * Returns user as an object.
    * @return user name;
    */
   Person getUser();
   
   void setUser(Person user);
   /**
    * Sets username without binding.
    * @param username to be associated with the context.
    */
   void setUserName(String username);


   /**
    * Returns mAttributes assigned to the context.
    * @return hashmap of mAttributes.
    */
   Map<Object, Object> getAttributes();

}
