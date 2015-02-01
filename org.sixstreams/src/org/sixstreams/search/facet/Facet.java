package org.sixstreams.search.facet;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.List;


public class Facet
   implements Serializable
{
   private FacetPath path;
   private List<FacetEntry> entries = new ArrayList<FacetEntry>();
   private transient FacetDef rootFacetDef;
   private String name;
   private String displayName;

/**
    * Constructs a Facet from a FacetDef
    * @param facetDef
    */
   public Facet(FacetDef facetDef)
   {
      rootFacetDef = facetDef;
      name = facetDef.getName();
      displayName = facetDef.getDisplayName();
   }

   public FacetDef getFacetDef()
   {
      return rootFacetDef;
   }

   /**
    * Gets the name of the facet.
    * @return
    */
   public String getName()
   {
      return name;
   }

   /**
    * Gets the display name of the facet.
    * @return String
    */
   public String getDisplayName()
   {
      return displayName;
   }

   /**
    * Gets the binding name of the facet.
    * @return String
    */
   public String getAttrName()
   {
      return rootFacetDef.getAttrName();
   }


   /**
    * Gets the entries for this facet.
    * @return FacetEntry[]
    */
   public List<FacetEntry> getEntries()
   {
      return entries;
   }

   public void addEntry(FacetEntry entry)
   {
      for (int i = 0; i < entries.size(); i++)
      {
         if (entry.getCount() >= entries.get(i).getCount())
         {
            entries.add(i, entry);
            return;
         }
      }
      entries.add(entry);
   }

   /**
    * Gets the path to this Facet.
    * @return FacetPath
    */
   public FacetPath getPath()
   {
      return path;
   }


   public void setPath(FacetPath facetPath)
   {
      this.path = facetPath;
   }

   public String getEntryDisplayValue(String value)
   {
      for (FacetEntry entry: entries)
      {
         if (value.equals(entry.getValue()))
         {
            return entry.getDisplayValue();
         }
      }
      return value;
   }

   public boolean isRangeSearchEnabled()
   {
      return getFacetDef().isRangeSearchEnabled();
   }
   public void clearEntries()
   {
      entries.clear();
   }

   public int getNoOfEntries()
   {
      return entries.size();
   }
}
