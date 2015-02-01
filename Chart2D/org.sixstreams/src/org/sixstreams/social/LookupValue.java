package org.sixstreams.social;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.data.java.annotations.Searchable;

@Searchable(title = "value", isSecure = false)
public class LookupValue extends IdObject
{
	private String code;
	private String value;
	private String language;
	//object type
	private String type;
	//attr name
	private String attrName;
	
	public String getCode()
	{
		return code;
	}
	public void setCode(String code)
	{
		this.code = code;
	}
	
	public String getValue()
	{
		return value;
	}
	public void setValue(String value)
	{
		this.value = value;
	}
	
	public String getLanguage()
	{
		return language;
	}
	
	public void setLanguage(String language)
	{
		this.language = language;
	}
	
	public String getType()
	{
		return type;
	}
	public void setType(String type)
	{
		this.type = type;
	}
	public String getAttrName()
	{
		return attrName;
	}
	public void setAttrName(String attrName)
	{
		this.attrName = attrName;
	}
}
