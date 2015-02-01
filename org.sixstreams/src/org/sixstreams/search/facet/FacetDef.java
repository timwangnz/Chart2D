package org.sixstreams.search.facet;

import java.io.Serializable;

import org.sixstreams.search.res.DefaultBundle;


public class FacetDef
   implements Serializable
{
   private String name;
   private String attrName;
   private boolean leaf;
   private FacetDef parentDef;
   private FacetDef childDef;
   private boolean rangeSearchEnabled;
   public FacetDef()
   {

   }

   public FacetDef(FacetDef parent, String name, String fieldName)
   {
      parentDef = parent;
      this.name = name;
      attrName = fieldName;
   }

   public FacetDef createChildDef(String name, String fieldName)
   {
      childDef = new FacetDef(this, name, fieldName);
      return childDef;
   }

   public String getDisplayName()
   {
      return DefaultBundle.getResource(this, name);
   }

   public void setName(String name)
   {
      this.name = name;
   }

   public String getName()
   {
      return name;
   }

   public void setAttrName(String attrName)
   {
      this.attrName = attrName;
   }

   public String getAttrName()
   {
      return attrName;
   }

   public FacetDef getChildDef()
   {
      return childDef;
   }

   public FacetDef getParentDef()
   {
      return parentDef;
   }


   public void setLeaf(boolean leafFacet)
   {
      leaf = leafFacet;
   }

   public boolean isLeaf()
   {
      return leaf;
   }

   public void setParentDef(FacetDef mParentDef)
   {
      this.parentDef = mParentDef;
   }

   public void setRangeSearchEnabled(boolean rangeSearchEnabled)
   {
      this.rangeSearchEnabled = rangeSearchEnabled;
   }

   public boolean isRangeSearchEnabled()
   {
      return rangeSearchEnabled;
   }
}
