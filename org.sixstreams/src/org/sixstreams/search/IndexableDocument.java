package org.sixstreams.search;

import java.util.List;

/**
 * An indexable document represents an instance of a searchable object
 * that can be indexed by a search engine.
 * <p>
 * <p>A search engine implementation should have its own implementation
 * of this interface to represent its internal data structure and expose
 * it per this interface.
 * <p>The implementation is consumed by various components.
 */
public interface IndexableDocument
   extends Document
{
   String DELETE = "DELETE";
   String UPDATE = "UPDATE";
   String INSERT = "INSERT";

   /**
    * Adds an attachment to this document. This will be used by crawler to
    * crawl data from lobs.
    *
    * @param attachment to be added to.
    */
   void addAttachment(Attachment attachment);

   /**
    * Returns a list of attachments this document contains.
    * @return a list of attachments.
    */
   List<Attachment> getAttachments();

   /**
    * Returns the action type required for the document.
    * @return the action type for this document.
    */
   String getActionType();

   /**
    * Sets the action type for the document.
    * <p>
    * Its values can be:
    * <ul>
    *   <li> IndexableDocument.DELETE</li>
    *   <li>IndexableDocument.UPDATE</li>
    *   <li>IndexableDocument.INSERT<li>
    * </ul>
    * @param actionType action to be performed on this document
    */
   void setActionType(String actionType);

   /**
    * Overrides access URL logic, and use the value assigned here.
    * @param accessURL the overriding URL for this document.
    */
   void overrideAccessURL(String accessURL);

   /**
    * Returns Url to access EBS detail page. This URL is formed based on the
    * form function specified by developers along with parameters.
    * @return EBS url.
    */
   String getAccessURL();

   /**
    * Sets acl to the field.
    * @param fieldName to which the acl is set.
    * @param acl list of values used as the acl for this document on this field.
    */
   void setAttribueAcl(String fieldName, List<String> acl);

   /**
    * Returns a list of acl per field name.
    * @param fieldName to which the acl is returned.
    * @return acl values for the field.
    */
   List<String> getAttributeAcl(String fieldName);

   /**
    * Returns a list of strings, the access list. If no ACL for the document,
    * it must return null.
    *
    * @return Access control list. Null if none.
    */
   List<String> getAcl();

}
