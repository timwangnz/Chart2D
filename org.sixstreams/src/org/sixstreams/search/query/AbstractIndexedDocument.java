package org.sixstreams.search.query;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import org.sixstreams.search.AbstractDocument;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.action.SearchAction;


public abstract class AbstractIndexedDocument
   extends AbstractDocument
   implements IndexedDocument
{
   protected static Logger sLogger = Logger.getLogger(AbstractIndexedDocument.class.getName());

   /**
    * Constructor
    **/
   public AbstractIndexedDocument(SearchableObject searchableObject)
   {
      super(searchableObject);
   }

   /**
    * Default Constrcutor
    */
   public AbstractIndexedDocument()
   {
   }

   /**
    * Returns mScore for this document
    * @return relevance mScore.
    */
   public long getScore()
   {
      return mScore;
   }

   /**
    * Sets mScore for this document.
    * @param score relevance mScore.
    */
   public void setScore(long score)
   {
      mScore = score;
   }

   /**
    *
    * @inheritDoc
    */

   public List<SearchAction> getActions()
   {

      return mActions;
   }

   /**
    *
    * @inheritDoc
    */
   public void overrideActions(List<SearchAction> actions)
   {
      if (actions == null)
      {
         throw new IllegalArgumentException("Actions must not be null when call overrideActions");
      }
      mActions = new ArrayList<SearchAction>(actions);

      if (getDefaultAction() == null)
      {
         throw new IllegalArgumentException("Actions must contain a default action");
      }
   }

   /**
    *
    * @inheritDoc
    */
   public SearchAction getDefaultAction()
   {
      List<SearchAction> actions = getActions();
      if (actions != null)
      {
         for (SearchAction action: actions)
         {
            if (action.isDefault())
            {
               return action;
            }
         }
      }
      return null;
   }
   private long mScore;
   protected List<SearchAction> mActions = new ArrayList<SearchAction>();

}

