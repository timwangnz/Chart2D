package org.sixstreams.search.query.action;

import java.util.HashMap;
import java.util.Map;

import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.meta.action.SearchResultActionDef;

public class SearchAction
{
   public static final String ACTION_TYPE_TASK = "Task";
   public static final String ACTION_TYPE_URL = "Url";

   private IndexedDocument indexedDocument;
   private SearchResultActionDef actionDef;
   private String title;
   private String name;
   private boolean defaultAction;
   private String type;
   private String target;
   private Map<String, Object> params = new HashMap<String, Object>();

   public SearchAction()
   {

   }

   public SearchAction(SearchResultActionDef actionDef)
   {

   }

   public void setDocument(IndexedDocument doc)
   {
      this.indexedDocument = doc;
   }

   public void setDefault(boolean defaultAction)
   {
      this.defaultAction = defaultAction;
   }

   public boolean isDefault()
   {
      return defaultAction;
   }

   public IndexedDocument getDoc()
   {
      return indexedDocument;
   }

   public void setActionDef(SearchResultActionDef actionDef)
   {
      this.actionDef = actionDef;
   }

   public SearchResultActionDef getActionDef()
   {
      return actionDef;
   }

   public void setTitle(String title)
   {
      this.title = title;
   }

   public String getTitle()
   {
      return title;
   }

   public void setName(String name)
   {
      this.name = name;
   }

   public String getName()
   {
      return name;
   }

   public void setType(String type)
   {
      this.type = type;
   }

   public String getType()
   {
      return type;
   }

   public Map<String, Object> getOverrideActionParams()
   {
      return params;
   }

   public void setTarget(String target)
   {
      this.target = target;
   }

   public String getTarget()
   {
      return target;
   }
}
