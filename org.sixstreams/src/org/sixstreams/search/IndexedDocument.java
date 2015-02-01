package org.sixstreams.search;

import java.util.List;

import org.sixstreams.search.query.action.SearchAction;


/**
 * The <code>IndexedDocument</code> class wraps a search hit. It is returned to
 * caller via @see SearchHits.
 */

public interface IndexedDocument
   extends Document
{
   /**
    * The plugin can call this method to override default action.
    * @param actions overriding search action.
    * @see SearchAction
    */
   void overrideActions(List<SearchAction> actions);

   /**
    * Returns default action for this document.
    * @return default search action.
    * @see SearchAction
    */
   SearchAction getDefaultAction();

   /**
    *A short description of this document.
    * @return a short description.
    */
   String getDescription();

   /**
    * Returns all actions available for this document.
    * @return search actions.
    * @see SearchAction
    */
   List<SearchAction> getActions();


   /**
    * Returns Score for this document
    * @return relevance Score.
    */
   long getScore();
}
