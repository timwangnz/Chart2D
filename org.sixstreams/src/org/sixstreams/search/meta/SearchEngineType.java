package org.sixstreams.search.meta;

import java.util.HashMap;
import java.util.Map;


public class SearchEngineType
{
   public SearchEngineType(long id)
   {
      this.mId = id;
   }

   public long getId()
   {
      return mId;
   }

   public String getName()
   {
      return mName;
   }

   public void setName(String name)
   {
      mName = name;
   }

   public void addParameter(String key, String value)
   {
      mDefaultParams.put(key, value);
   }

   public Map<String, String> getParameters()
   {
      return mDefaultParams;
   }

   public void setEngineImplType(String implName)
   {
      mImplType = implName;
   }

   public String getEngineImplType()
   {
      return mImplType;
   }

   public MetaEngineInstance createEngine(long id, String name)
   {
      MetaEngineInstance engine = new MetaEngineInstance();
      engine.setName(name);
      engine.setEngineTypeId(mId);
      engine.setId(id);
      Map<String, String> params = getParameters();
      engine.setEngineType(getEngineImplType());
      for (String key: params.keySet())
      {
         engine.addParameter(key, params.get(key));
      }
      return engine;
   }

   private long mId;
   private String mImplType;
   private String mName;
   private Map<String, String> mDefaultParams = new HashMap<String, String>();
}
