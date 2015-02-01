package org.sixstreams.rest.writers;

import java.io.Serializable;
import java.util.Map;

import org.sixstreams.search.data.java.ListOfValues;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.util.ClassUtil;

public class AttrDef implements Serializable
{
   String name;
   String displayName;
   //String groupDisplayName;
   String type;
   String group;
   int seq;
   boolean displayable;
   boolean updatable;
   boolean primaryKey;
   boolean required;
   boolean searchable;
   boolean filterable;
   String readableType;
   String aggregateFunction;
   String lovDef;
   String listType;
   
   Map<String, Object> listOfValues;
   
   public AttrDef(AttributeDefinition p0)
   {
      name = p0.getName();
      displayName = p0.getDisplayName();
      //group = p0.getGroupName();
      //group = group == null? "undefined": group;

      //groupDisplayName = ctx.getResourceString(p0, group);
      type = p0.getDataType();
      seq = p0.getSequence();
      updatable = false;
      primaryKey = p0.isPrimaryKey();
      searchable = true;
      filterable = true;
      required = p0.isRequired();
      displayable = p0.isDisplayable();
      readableType = p0.getReadableType();
      listType = p0.getListType();
      aggregateFunction = p0.getAggregateFunction();
      lovDef = p0.getLovDef();
      if (lovDef != null && lovDef.trim().length() > 0)
      {
    	  ListOfValues lov = (ListOfValues) ClassUtil.create(lovDef);
    	  if (lov != null)
    	  {
    		  listOfValues = lov.getLov();
    	  }
    	  else
    	  {
    		  System.err.println("Failed to load lov " +  lovDef);
    	  }
      }
   }
}
