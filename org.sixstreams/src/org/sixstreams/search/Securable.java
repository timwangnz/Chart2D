package org.sixstreams.search;

import java.util.List;


/**
 * A securable is an interface to be implemented for seucrity plugin
 * to enforce custom security rules on the searchable objects. Each searchable
 * object can be associated with a plugin that might implement this interface.
 * <p>
 */
public interface Securable
{
   /**
    * Tests if this plug-in enables ACL security or not. If this returns false,
    * @see #getAcl and #getSecurityKeys method will not be called.
    * @return whether ACL is enabled.
    */
   boolean isAclEnabled();

   /**
    * This is the mechanism to enforce applications security.
    * This method is called at crawl time to create a locker for each
    * document. A locker is a list of strings returned by this method.
    *
    * <p>The implementation must create
    * an effective locker for each indexable document that requires access controls.
    *
    * For SES, each string in the list must be either or a combination of the following
    * two:
    * <ul>
    * <li>number<li>
    * <li>Capital Alphabet</li>
    * </ul>
    *
    * application context..
    * @param indexableDocument needed to be locked.
    * @throws org.sixstreams.SearchSecurityException You must throw a SearchSecurityException
    * if the document does not satisfy your security rules. The exception
    * will result this document not indexed in the index store.
    */
   List<String> getAcl(IndexableDocument indexableDocument)
      throws SearchSecurityException;


   /**
    * Returns a list of keys owned by the session user, identified by session
    * information passed in through ctx.
    * <p>
    * You must use the defined way to access user object via the context passed by.
    * For more details, @see SearchConext.
    * <p>If hash function is used in getAcl, the same hash function should be
    * used to form the key.
    *
    * @return keys for a given search.
    * @throws org.sixstreams.SearchSecurityException if for some reason the context passed to
    * does not satisfy your security rules. This will result a security violation
    * message for UI component to display.
    */
   List<String> getSecurityKeys()
      throws SearchSecurityException;

   /**
    * SES implemenation. It works as this:
    * <p>
    * For a searchable object, one can norminate one or more mAttributes
    * as security attribute. For these mAttributes, the framework will call
    * this method to get list of keys to form a security filter and pass to SES.
    * @param attributeName name of the security attribute.
    */
   List<String> getSecureAttrKeys(String attributeName)
      throws SearchSecurityException;

   /**
    * SES implemenation. This method is called when crawling. The
    * crawler calls this method to get specific ACL list for the nominated
    * security mAttributes.
    */
   List<String> getSecureAttrAcl(IndexableDocument document, String attributeName)
      throws SearchSecurityException;

   /**
    * This method is used to return a list of the names of the configuration
    * parameters used by the security plug-in.
    * security mAttributes.
    */
   List<String> getSecurableParams()
      throws SearchSecurityException;

}
