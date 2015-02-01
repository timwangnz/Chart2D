package org.sixstreams.search;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.sixstreams.Constants;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.meta.SearchableObject;

import com.google.gson.Gson;

public class AttributeFilter implements Serializable
{
	private String name;
	private Object value;

	private Object hiValue;
	private Object loValue;
	private String attrbuteType;

	private String operator;
	
	public static Collection<AttributeFilter> fromQuery(String objectName, String queryString)
	{
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		String[] filterElements = queryString.split(";");
		
		SearchableObject so = MetaDataManager.getSearchableObject(objectName);
		
		for(String element : filterElements)
		{
			String[] filter = element.split(":");
			
			String dataType = so.getDocumentDef().getAttributeDef(filter[0]).getDataType();
			
			filters.add(new AttributeFilter(filter[0], dataType, filter[1], Constants.OPERATOR_EQS));
		}
		return filters;
	}
	
	public static List<AttributeFilter> fromJson(String jsonFilters)
	{
		Gson gson = new Gson();
		List<AttributeFilter> filters = new ArrayList<AttributeFilter>();
		AttributeFilter[] newFilters = (AttributeFilter[]) gson.fromJson(jsonFilters, AttributeFilter[].class);
		filters = new ArrayList<AttributeFilter>();
		for (AttributeFilter filter : newFilters)
		{
			filters.add(filter);
		}
		return filters;
	}

	public AttributeFilter(String attrName)
	{
		this.name = attrName;
	}

	public void assign(AttributeFilter attributeFilter)
	{
		this.value = attributeFilter.value;
		this.hiValue = attributeFilter.hiValue;
		this.loValue = attributeFilter.loValue;
		this.attrbuteType = attributeFilter.attrbuteType;
		this.operator = attributeFilter.operator;
	}

	/**
	 * Constructs a filter object
	 * 
	 * @param attrName
	 *            name of the mName this filter is applied
	 * @param attrType
	 *            data type of the attribute this filter is applied, if null is
	 *            given, String type is assumed.
	 * @param value
	 *            that forms the predicate
	 * @param operator
	 *            a string representation of the operation. This is searchable
	 *            engine dependent. See more details in SES query language.
	 */

	public AttributeFilter(String attrName, String attrType, Object value, String operator)
	{

		// assert(value != null, "Value can not be null");
		this.name = attrName;
		this.value = value;
		this.operator = operator;
		this.attrbuteType = attrType == null ? String.class.getName() : attrType;
	}

	public AttributeFilter(String attrName, String attrType, Object loValue, Object hiValue)
	{
		this.name = attrName;
		this.hiValue = hiValue;
		this.loValue = loValue;
		this.operator = Constants.OPERATOR_RANGE;
		this.attrbuteType = attrType == null ? String.class.getName() : attrType;
	}

	/**
	 * Returns mName name to be predicated on.
	 * 
	 * @return mName name.
	 */
	public String getAttrName()
	{
		return name;
	}

	/**
	 * Returns the mValue to be predicated.
	 * 
	 * @return mName mValue.
	 */
	public Object getAttrValue()
	{
		return value;
	}

	/**
	 * Returns filter mOperator.
	 * 
	 * @return mOperator.
	 */
	public String getOperator()
	{
		return operator;
	}

	public boolean isEqual(AttributeFilter attrFilter)
	{
		if (this == attrFilter)
		{
			return true;
		}

		if (attrFilter == null)
		{
			return false;
		}

		if (!(name == null ? attrFilter.name == null : name.equals(attrFilter.name)))
		{
			return false;
		}

		if (!(value == null ? attrFilter.value == null : value.equals(attrFilter.value)))
		{
			return false;
		}

		if (!(operator == null ? attrFilter.operator == null : operator.equals(attrFilter.operator)))
		{
			return false;
		}
		if (!(loValue == null ? attrFilter.loValue == null : loValue.equals(attrFilter.loValue)))
		{
			return false;
		}
		if (!(hiValue == null ? attrFilter.hiValue == null : hiValue.equals(attrFilter.hiValue)))
		{
			return false;
		}

		return true;
	}

	public void setAttrbuteType(String attrbuteType)
	{
		this.attrbuteType = attrbuteType;
	}

	public String getAttrbuteType()
	{
		return attrbuteType;
	}

	public Object getHiValue()
	{
		return hiValue;
	}

	public Object getLoValue()
	{
		return loValue;
	}

	public String toString()
	{
		if (this.value != null)
		{
			return this.name + " " + this.operator + " " + this.value + " data type " + this.attrbuteType;
		}
		else
		{
			return this.name + " " + this.operator + " " + this.loValue + " to " + this.hiValue + " data type " + this.attrbuteType;
		}
	}


}
