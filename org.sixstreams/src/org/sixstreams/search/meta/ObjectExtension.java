package org.sixstreams.search.meta;

public class ObjectExtension
{
   private String context = "";
   private String relatedObjects = "";
   private String template = "";
   private SearchableObject mSearchableObject;

   public ObjectExtension(SearchableObject object)
   {
      setSearchableObject(object);
   }

   public void setContext(String context)
   {
      this.context = context;
   }

   public String getContext()
   {
      return context;
   }

   public void setRelatedObjects(String relatedObjects)
   {
      this.relatedObjects = relatedObjects;
   }

   public String getRelatedObjects()
   {
      return relatedObjects;
   }

   public void setTemplate(String template)
   {
      this.template = template;
   }

   public String getTemplate()
   {
      return template;
   }

   public void setSearchableObject(SearchableObject searchableObject)
   {
      this.mSearchableObject = searchableObject;
   }

   public SearchableObject getmSearchableObject()
   {
      return mSearchableObject;
   }
}
