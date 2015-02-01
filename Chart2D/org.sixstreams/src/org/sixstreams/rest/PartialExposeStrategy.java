package org.sixstreams.rest;

import java.util.ArrayList;
import java.util.List;

import com.google.gson.ExclusionStrategy;
import com.google.gson.FieldAttributes;

public class PartialExposeStrategy implements ExclusionStrategy
{
	private List<String> fields = new ArrayList<String>();
	String className;
	boolean including;
	public PartialExposeStrategy(boolean including, String className, List<?> names)
	{
		this.including = including;
		this.className = className;
		if (names != null)
		{
			for (Object name : names)
			{
				fields.add("" + name);
			}
		}
	}

	public boolean shouldSkipField(FieldAttributes fieldAttributes)
	{
		if (fields.size() == 0)
		{
			return false;//this shoudl not happen, as we will set rules if the fileds count is larger than 0
		}
		
		return including ? !fields.contains(fieldAttributes.getName())
						: fields.contains(fieldAttributes.getName()); 
	}

	public boolean shouldSkipClass(Class<?> class1)
	{
		return false;
	}
}
