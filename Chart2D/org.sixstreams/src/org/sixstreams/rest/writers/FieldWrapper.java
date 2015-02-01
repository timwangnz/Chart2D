package org.sixstreams.rest.writers;

import java.io.Serializable;
import java.lang.reflect.Field;

public class FieldWrapper implements Serializable
{
	private String name;
	private String type;
	private String displayName;

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getType()
	{
		return type;
	}

	public void setType(String type)
	{
		this.type = type;
	}

	public String getDisplayName()
	{
		return displayName;
	}

	public void setDisplayName(String displayName)
	{
		this.displayName = displayName;
	}

	public FieldWrapper()
	{
		super();
	}

	FieldWrapper(Field p0)
	{
		name = p0.getName();
		type = p0.getType().getName();
		displayName = name;
	}
}
