package org.sixstreams.search.impl;

public interface ExpressionEvaluator
{
   public Object evaluate(String expr);

   public void setEntity(Object entity);
}
