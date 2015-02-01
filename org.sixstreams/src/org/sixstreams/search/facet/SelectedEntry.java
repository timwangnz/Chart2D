package org.sixstreams.search.facet;

import java.io.Serializable;

import org.sixstreams.search.res.DefaultBundle;

public class SelectedEntry
   implements Serializable
{
   private static final long serialVersionUID = 1L;
   private String attrName;
   private String value;
   private String facetName;
   private int depth;
   private boolean leaf;

   public int getDepth()
   {
      return depth;
   }

   public SelectedEntry(String facetName, String fieldName, String facetValue, int depth, boolean leaf)
   {
      this.facetName = facetName;
      this.attrName = fieldName;
      this.value = facetValue;
      this.depth = depth;
      this.leaf = leaf;
   }

   public String getDisplayValue()
   {
      return DefaultBundle.getResource(this, value);
   }

   public String toString()
   {
      return this.getDisplayValue();
   }

   public String getValue()
   {
      return value;
   }

   public String getFacetName()
   {
      return facetName;
   }

   public String getAttrName()
   {
      return attrName;
   }

   public void setLeaf(boolean leaf)
   {
      this.leaf = leaf;
   }

   public boolean isLeaf()
   {
      return leaf;
   }
}
