package org.sixstreams.search.facet;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;

import org.sixstreams.Constants;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.SearchableObject;


public class FacetManager
{
   private FacetManager()
   {
   }

   /**
    * Construct query Filters from Facet Paths.
    * @param so - searchable object which has facet def.
    * @param paths - the facet paths containing facet selections for the searchable object.
    * @return Filter[]
    */
   public static List<AttributeFilter> getFilters(SearchableObject so, Collection<FacetPath> paths)
   {
      ArrayList<AttributeFilter> filterList = new ArrayList<AttributeFilter>();
      // for each facet path, construct a filter for each of its selections.
      for (FacetPath facetPath: paths)
      {
         List<SelectedEntry> facetSels = facetPath.getSelections();
         if (facetSels.size() > 0)
         {
            // first, start with the root facet in each path.
            // need facetDefs to get the bound column for which to create a filter.
            FacetDef facetDef = findFacetDef(facetSels.get(0).getFacetName(), so.getFacetDefs());

            if (facetDef == null)
            {
               continue;
            }

            // for each facet selection, construct a filter
            for (SelectedEntry facetSel: facetSels)
            {
               // get fieldDef from facetName
               AttributeDefinition attrDef = so.getDocumentDef().getAttributeDef(facetDef.getAttrName());
               Object attrValue = facetSel.getValue();
               AttributeFilter filter =
                  new AttributeFilter(attrDef.getName(), attrDef.getDataType(), attrValue, Constants.OPERATOR_EQS);
               filterList.add(filter);
               facetDef = facetDef.getChildDef();
            }
         }
      }
      return filterList;
   }

   /**
    * Get the Facets for a given SearchableObject based on selected FacetPaths.
    * @param so
    * @param facetPaths
    * @return Facet[]
    */
   public static List<Facet> getFacets(SearchableObject so, Collection<FacetPath> facetPaths)
   {
      // put facetPaths into a map
      HashMap<String, FacetPath> facetPathsMap = new HashMap<String, FacetPath>();
      if (facetPaths != null)
      {
         for (FacetPath facetPath: facetPaths)
         {
            if (facetPath.getSelections().size() > 0)
            {
               String topLevelFacetName = facetPath.getSelections().get(0).getFacetName();
               facetPathsMap.put(topLevelFacetName, facetPath);
            }
         }
      }

      ArrayList<Facet> facetList = new ArrayList<Facet>();

      for (FacetDef facetDef: so.getFacetDefs())
      {
         // create a Facet from the root FacetDef since no facet path
         Facet facet = new Facet(facetDef);
         FacetPath facetPath = (FacetPath) facetPathsMap.get(facetDef.getName());
         if (facetPath == null)
         {
            facetPath = new FacetPath(facet);
            facetPathsMap.put(facetDef.getName(), facetPath);
         }
         facetList.add(facet);
         facet.setPath(facetPath);
      }

      return facetList;
   }

   private static FacetDef findFacetDef(String facetName, List<FacetDef> facetDefs)
   {
      for (FacetDef facetDef: facetDefs)
      {
         if (facetDef.getName().equals(facetName))
         {
            return facetDef;
         }
      }
      return null;
   }
}
