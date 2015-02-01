package org.sixstreams.metadata;

import org.sixstreams.search.data.DataCommon;


public class MetaDataCommon extends DataCommon
{
   private String name;
   private String realm;
   
   public void setName(String name)
   {
      this.name = name;
   }

   public String getName()
   {
      return name;
   }

   public void setRealm(String realm)
   {
      this.realm = realm;
   }

   public String getRealm()
   {
      return realm;
   }
}
