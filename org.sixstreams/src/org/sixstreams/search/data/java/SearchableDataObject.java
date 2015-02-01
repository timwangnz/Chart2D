package org.sixstreams.search.data.java;

import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.facet.FacetDef;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.util.ClassUtil;

public class SearchableDataObject
   extends SearchableObject
{
   private Class<?> clazz;

   public SearchableDataObject()
   {
      //does nothing
   }

   public SearchableDataObject(String name)
   {
      super(name);
      init(name);
   }

   public void setName(String name)
   {
      super.setName(name);
      init(name);
   }

   public DocumentDefinitionImpl cretaeDocumentDef()
   {
      String className = MetaDataManager.getProperty("org.sixstreams.java.document.definition.class");
      if (className == null)
      {
         return new DocumentDefinitionImpl(this, clazz);
      }
      else
      {
         DocumentDefinitionImpl docDef = (DocumentDefinitionImpl) ClassUtil.create(className);
         docDef.setSearchableObject(this);
         docDef.setClazz(clazz);
         docDef.init();
         return docDef;
      }
   }

   public SearchableDataObject(Class<?> clazz)
   {
      super(clazz.getName());
      this.clazz = clazz;
      setDocumentDef(cretaeDocumentDef());
   }

   public void init(String className)
   {
      clazz = ClassUtil.getClass(className);
      setDocumentDef(cretaeDocumentDef());
   }

   private static final String FACET_NAME_DELIMITOR = "\\.";

   public void addSearchFacetDef(String facetName, String facetPath, boolean rangeSearchEnabled)
   {
      String[] fieldNames = facetPath.split(FACET_NAME_DELIMITOR);
      FacetDef parent = getRootFacetDef(facetName, fieldNames[0]);
      for (int i = 1; i < fieldNames.length; i++)
      {
         FacetDef childDef = parent.getChildDef();
         if (childDef == null)
         {
            childDef = parent.createChildDef(facetName, fieldNames[i]);
            childDef.setRangeSearchEnabled(rangeSearchEnabled);
         }
         parent = parent.getChildDef();
      }
   }

   private FacetDef getRootFacetDef(String facetName, String fieldName)
   {
      FacetDef root = null;
      for (FacetDef sfd: getSearchFacetDefs())
      {
         if (sfd.getName().equals(facetName))
         {
            root = sfd;
         }
      }

      if (root == null)
      {
         root = new FacetDef(null, facetName, fieldName);
         addSearchFacetDef(root);
      }
      return root;
   }

   public IndexableDocument createIndexableDocument(Object obj)
   {
      if (clazz.isInstance(obj))
      {
         IndexableDocument doc = super.createIndexableDocument();
         assign(doc, obj);
         return doc;
      }
      else
      {
         throw new IllegalArgumentException("Object is not instance of " + clazz);
      }
   }

   public void assign(IndexableDocument doc, Object valueObject)
   {
      DocumentDefinitionImpl docDef = (DocumentDefinitionImpl) getDocumentDef();
      if (docDef != null)
      {
         docDef.assign(doc, valueObject);
      }
   }
}
