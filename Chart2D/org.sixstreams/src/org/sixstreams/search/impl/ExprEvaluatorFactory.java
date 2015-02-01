package org.sixstreams.search.impl;

import org.sixstreams.search.Document;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.util.ClassUtil;

public class ExprEvaluatorFactory
{
   private final static String EXPRESSION_EVALUATOR = "org.sixstreams.search.expression.evaluator";

   public static ExpressionEvaluator getEvaluator(Document object)
   {
      String property = MetaDataManager.getProperty(EXPRESSION_EVALUATOR);
      if (property == null)
      {
         property = SimpleExprEvaluator.class.getName();
      }

      ExpressionEvaluator ee = (ExpressionEvaluator) ClassUtil.create(property);
      if (ee == null)
      {
         throw new RuntimeException("Can not create expression evaluator " + property);
      }
      ee.setEntity(object);
      return ee;
   }

   private ExprEvaluatorFactory()
   {

   }
}
