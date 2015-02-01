package org.sixstreams.search.meta;

import java.io.Serializable;

import java.util.HashMap;


public class SearchPluginDef
   implements Serializable
{
   private String mClassName;
   private HashMap<String, String> mParametersMap;

   public SearchPluginDef(String name, HashMap<String, String> map)
   {
      mClassName = name;
      mParametersMap = map;
   }

   public String getClassName()
   {
      return mClassName;
   }


   public HashMap<String, String> getParametersMap()
   {
      return mParametersMap;
   }
}
