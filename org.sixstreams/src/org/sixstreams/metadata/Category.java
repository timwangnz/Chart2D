package org.sixstreams.metadata;


import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.data.java.annotations.Searchable;


@Searchable(title = "name")
public class Category
   extends MetaDataCommon
{
   private List<String> objects = new ArrayList<String>();

   public void setObjects(List<String> objects)
   {
      this.objects = objects;
   }

   
   public List<String> getObjects()
   {
      return objects;
   }
}
