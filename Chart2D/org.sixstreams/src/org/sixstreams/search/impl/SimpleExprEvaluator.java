package org.sixstreams.search.impl;

import org.sixstreams.search.Document;

public class SimpleExprEvaluator
   implements ExpressionEvaluator
{
   private Document document;

   public Object evaluate(String expr)
   {
      if (document == null)
      {
         //TODO warn
         return expr;
      }
      return document.getAttrValue(expr);
   }

   public void setEntity(Object entity)
   {
      if (entity instanceof Document)
      {
         document = (Document) entity;
      }
      else
      {
         throw new IllegalArgumentException("Expecting " + Document.class.getName());
      }

   }
}
