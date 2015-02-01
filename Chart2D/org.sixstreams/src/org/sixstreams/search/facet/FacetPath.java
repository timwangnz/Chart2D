package org.sixstreams.search.facet;

import java.io.Serializable;

import java.util.LinkedList;
import java.util.List;


public class FacetPath
   implements Serializable
{
   /**
    * Constructor for FacetPath with no facet selections.
    */
   public FacetPath(Facet facet)
   {
      this.facet = facet;
   }

   public Facet getFacet()
   {
      return facet;
   }

   public void setFacet(Facet facet)
   {
      this.facet = facet;
   }

   /**
    * Adds a facet selection to the mPath.
    * @param value - the value selected for the facet.
    */
   public FacetPath select(String value)
   {
      // copy to bigger array
      FacetDef facetDef = facet.getFacetDef();
      String fieldName = facetDef.getAttrName();
      int i = 0;
      while (facetDef != null)
      {
         fieldName = facetDef.getAttrName();
         if (i++ >= selections.size())
         {
            break;
         }
         facetDef = facetDef.getChildDef();
      }
      // add the new entry to the end
      if (selections.size() > 0)
      {
         selections.getLast().setLeaf(false);
      }
      selections.addLast(new SelectedEntry(facet.getName(), fieldName, value, i, true));
      return this;
   }

   public String getAttrName()
   {
      FacetDef facetDef = facet.getFacetDef();
      int i = 0;
      while (facetDef != null)
      {
         if (i++ >= selections.size())
         {
            break;
         }
         facetDef = facetDef.getChildDef();
      }

      if (facetDef == null)
      {
         return null;
      }
      else
      {
         return facetDef.getAttrName();
      }
   }

   /**
    * Gets the selections.
    * @return FacetSelection[]
    */
   public List<SelectedEntry> getSelections()
   {
      return selections;
   }

   /**
    * Get just the values for the selections.
    * @return String[]
    */
   public List<String> getValues()
   {
      // get the values of the selections
      LinkedList<String> listvalues = new LinkedList<String>();
      for (SelectedEntry entry: selections)
      {
         listvalues.add(entry.getValue());
      }

      return listvalues;
   }

   public FacetPath removeSelection()
   {
      selections.removeLast();
      if (!selections.isEmpty())
      {
         selections.getLast().setLeaf(true);
      }
      return this;
   }

   public String toString()
   {
      StringBuffer s = new StringBuffer();

      s.append("[");
      if (selections != null)
      {
         for (SelectedEntry sel: selections)
         {
            if (s.length() > 1)
            {
               s.append(", ");
            }

            if (sel != null)
            {
               s.append(sel.getFacetName() + "." + sel.getAttrName()).append(":").append(sel.getValue());
            }
            else
            {
               s.append("null");
            }
         }
      }
      s.append("]");

      return s.toString();
   }

   /**
    * Equals if thier facet selections are equal via Arryas.equals
    * @param facetPath the FacetPath to be tested.
    * @return true if they equal.
    */
   public boolean isEqual(FacetPath facetPath)
   {
      if (this == facetPath)
      {
         return true;
      }

      if (facetPath == null)
      {
         return false;
      }
      return selections.equals(facetPath.selections);
   }
   private LinkedList<SelectedEntry> selections = new LinkedList<SelectedEntry>();
   private transient Facet facet;
}
