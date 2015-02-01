package org.sixstreams.search.meta.action;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;


public class SearchResultActionDef implements Serializable
{
   protected static Logger sLogger = Logger.getLogger(SearchResultActionDef.class.getName());

   private String name;
   private String target;
   private String type;
   private String title;
   private boolean defaultAction;
   private HashMap<String, Object> parametersMap = null;
   private HashMap<String, String> parameterExpressionsMap = null;

   /**
    * Generic constructor for a definition.
    * @param name of the action.
    * @param title of the action.
    * @param type of the action, either TASK or URL.
    * @param target of the action. It is normally an action.
    * @param isDefault whether this action is the default action of a searchable object.
    * @param param list of configuration parameters for this action.
    */
   public SearchResultActionDef(String name, String title, String type, String target, boolean isDefault,
                                Map<String, Object> param)
   {
      this.defaultAction = isDefault;
      this.name = name;
      this.title = title;
      this.target = target;
      this.type = type;
      if (param != null)
      {
         this.parametersMap = new HashMap<String, Object>(param);
      }
   }

   public String getName()
   {
      return name;
   }

   public String getTarget()
   {
      return target;
   }

   public String getType()
   {
      return type;
   }

   public String getTitle()
   {
      return title;
   }


   public boolean isDefaultAction()
   {
      return defaultAction;
   }

   public HashMap<String, Object> getParamMap()
   {
      return parametersMap;
   }

   public HashMap<String, String> getParamExpressionsMap()
   {
      if (parametersMap != null && parameterExpressionsMap == null)
      {
         parameterExpressionsMap = new HashMap<String, String>();

         Set<String> keys = parametersMap.keySet();
         Iterator<String> iter = keys.iterator();
         while (iter.hasNext())
         {
            String key = (String) iter.next();
            String value = (String) parametersMap.get(key);

            //ExprEval expr = new ExprEval(value, ExprEval.EXPR_STYLE_GROOVY);
            parameterExpressionsMap.put(key, value);
         }
      }
      return parameterExpressionsMap;
   }
}

