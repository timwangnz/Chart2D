package org.sixstreams.search.query.action;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.Document;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.impl.ExprEvaluatorFactory;
import org.sixstreams.search.impl.ExpressionEvaluator;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.meta.action.SearchResultActionDef;
import org.sixstreams.search.res.DefaultBundle;


public class ActionURLResolver
{
   private static Logger sLogger = Logger.getLogger(ActionURLResolver.class.getName());

   /**
    * Returns evaluated task parameters for a given action.
    * @return HashMap containing the evaluated task parameters for an action.
    */
   public HashMap<String, Object> evaluateTaskParams(SearchAction actionInst)
      throws SearchException
   {
      HashMap<String, Object> params = new HashMap<String, Object>();

      if (!SearchAction.ACTION_TYPE_TASK.equals(actionInst.getType()))
      {
         throw new SearchException("Cannot evaluate task parameters for action that is not of type Task");
      }

      params = evaluateActionParams(actionInst);
      return params;
   }

   /**
    * Returns evaluated title of the action.
    * @param actionInst
    * @return String
    */
   public String evaluateTitle(SearchAction actionInst)
      throws SearchException
   {
      String title = null;

      Document doc = null;


      // Normally, title is an expression that should be evaluated.
      // However, in the case of the overriden-type action generated for an
      // External Search Object, the title will be a simple string like "Default".
      // We could construct a document from custom attrs and evaluate, but since
      // there is no expression and because they can't write plugins to override
      // the title, there is no need. Just return the hardcoded title string.
      if (actionInst.getName() == null)
      {
         return actionInst.getTitle();
      }

      try
      {
         doc = actionInst.getDoc();
         title = evaluateTitle(doc, actionInst);
      }
      catch (Exception e)
      {
         throw new SearchException("Could not evaluate action title expression " + " for action: " +
                                   actionInst.getName(), e);


      }

      return title;
   }


   /**
    * Returns the evaluated action params for a given action. This is a low-level
    * api that is internally called by resolveURL() and evaluateTaskParams().
    * @param actionInst
    * @return
    * @throws SearchException
    */
   public HashMap<String, Object> evaluateActionParams(SearchAction actionInst)
      throws SearchException
   {

      HashMap<String, Object> params = new HashMap<String, Object>();

      Document doc = null;

      // if override exists, just return that
      if (actionInst.getOverrideActionParams() != null)
      {
         if (sLogger.isLoggable(Level.FINE))
         {
            sLogger.log(Level.FINE, "ActionURLResolver is returning override task params");
         }

         return new HashMap<String, Object>(actionInst.getOverrideActionParams());
      }

      try
      {
         doc = actionInst.getDoc();
         params = evaluateActionParams(doc, actionInst);

         if (sLogger.isLoggable(Level.FINE))
         {
            sLogger.log(Level.FINE,
                        "Action Params for action: " + actionInst.getName() + " evaluated using stored attrs.");
         }
      }
      catch (Exception e)
      {
         throw new SearchException("Could not evaluate action param expressions" + " for action: " +
                                   actionInst.getName(), e);
      }
      return params;
   }


   private HashMap<String, Object> evaluateActionParams(Document doc, SearchAction actionInst)
   {
      // get the full action definition (which has expressions to evaluate).
      SearchResultActionDef actionDef = getSearchActionDef(actionInst);

      // evaluate param expressions
      HashMap<String, Object> params = null;
      try
      {
         params = evaluateActionParamExprs(actionDef.getParamExpressionsMap(), doc);
      }
      catch (SearchException e)
      {
         if (sLogger.isLoggable(Level.FINE))
         {
            sLogger.log(Level.FINE, "No parameters defined for action: " + actionInst.getName());
         }
      }

      return params;
   }


   private HashMap<String, Object> evaluateActionParamExprs(HashMap<String, String> paramExprs, Document doc)
      throws SearchException
   {
      HashMap<String, Object> paramMap = new HashMap<String, Object>();

      if (paramExprs != null)
      {
         ExpressionEvaluator valSupplier = ExprEvaluatorFactory.getEvaluator(doc);

         Set<String> keys = paramExprs.keySet();
         Iterator<String> iter = keys.iterator();
         while (iter.hasNext())
         {
            // get each param expr
            String key = (String) iter.next();
            String paramExpr = (String) paramExprs.get(key);

            // evaluate the param expr
            if (paramExpr != null)
            {
               Object value = valSupplier.evaluate(paramExpr);
               if (value != null)
               {
                  // store value in result map
                  paramMap.put(key, value);
               }
            }
         }
      }
      else
      {
         throw new SearchException("Null param exprs");
      }

      return paramMap;
   }

   //expose this simple evaluation method

   public String evaluate(Document doc, String expression)
   {
      if (expression == null)
      {
         return null;
      }
      String evaluatedString = null;
      try
      {
         // ExprEval targetExpr = new ExprEval(expression, ExprEval.EXPR_STYLE_GROOVY);
         
            // evaluate the url expression
            ExpressionEvaluator valSupplier = ExprEvaluatorFactory.getEvaluator(doc);
            Object value = valSupplier.evaluate(expression);
            if (value != null)
            {
               evaluatedString = value.toString();
            }
            else
            {
               sLogger.fine("Null returned on evaluating " + expression);
            }
         
   
      }
      catch (Exception e)
      {
         sLogger.log(Level.WARNING, DefaultBundle.getResource(DefaultBundle.WARNING_ACTION_URL_RESOLVER_EVALUATE_EXPRESSION) +
                     expression, e);
      }
      return evaluatedString;
   }


   /**
    * Evaluate the target of an action.
    * @param actionInst
    * @return String
    */
   public String evaluateActionTarget(SearchAction actionInst)
   {
      String url = actionInst.getTarget();

      Document doc = actionInst.getDoc();
      SearchResultActionDef actionDef = getSearchActionDef(actionInst);
      if (actionDef != null)
      {
         String expr = actionDef.getTarget();

         if (expr != null)
         {
            ExpressionEvaluator valSupplier = ExprEvaluatorFactory.getEvaluator(doc);

            Object value = valSupplier.evaluate(expr);
            if (value != null)
            {
               url = value.toString();
            }
         }
      }
      return url;
   }

   /**
    * Evaluate the title of an action.
    * @param doc
    * @param actionInst
    * @return String
    */
   private String evaluateTitle(Document doc, SearchAction actionInst)
   {
      String title = actionInst.getTitle();

      // get the full action definition (which has expressions to evaluate).
      SearchResultActionDef actionDef = getSearchActionDef(actionInst);
      if (actionDef != null)
      {
         String expr = actionDef.getTitle();

         // evaluate the expression
         if (expr != null)
         {
            ExpressionEvaluator valSupplier = ExprEvaluatorFactory.getEvaluator(doc);
            Object value = valSupplier.evaluate(expr);
            if (value != null)
            {
               title = value.toString();
            }
         }
      }
      return title;
   }

   /**
    * Generate the real url for any action by evaluating expessions using the doc.
    * @param actionInst
    * @return
    */
   public String evaluateURL(SearchAction actionInst)
      throws SearchException
   {
      String url = null;

      if (SearchAction.ACTION_TYPE_URL.equals(actionInst.getType()))
      {
         url = evaluateActionTarget(actionInst);
      }

      return url;
   }

   /**
    * Gets the search action def by name from a searchable view object.
    * @return SearchResultActionDef
    */
   private SearchResultActionDef getSearchActionDef(SearchAction actionInst)
   {
      SearchResultActionDef[] actionDefs;
      if (actionInst.getDoc() == null)
      {
         SearchableObject searchableObject = actionInst.getDoc().getSearchableObject();
         actionDefs = searchableObject.getSearchActions();
      }
      else
      {
         actionDefs = actionInst.getDoc().getSearchableObject().getSearchActions();
      }

      if (actionDefs != null)
      {
         for (int i = 0; i < actionDefs.length; i++)
         {
            if (actionInst.getName().equals(actionDefs[i].getName()))
            {
               return actionDefs[i];
            }
         }
      }
      return null;
   }
}
