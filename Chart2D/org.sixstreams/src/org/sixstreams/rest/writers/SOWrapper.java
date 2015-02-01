package org.sixstreams.rest.writers;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.meta.SearchableObject;

public class SOWrapper implements Serializable
{
	public SOWrapper(SearchableObject so)
	{
		name = so.getName();
		displayName = so.getDisplayName();
		for (AttributeDefinition field : so.getDocumentDef().getAttrDefs())
		{
			// should not add here is it is transient

			if ("class".equals(field.getName()))
			{
				continue;
			}
			attributes.add(new AttrDef(field));
			/*
			 * String groupName = field.getGroupName(); groupName = groupName ==
			 * null ? "Ungrouped" : groupName; SearchContext ctx =
			 * ContextFactory.getSearchContext(); groupName =
			 * ctx.getResourceString(so, groupName); List<AttrDef> fields =
			 * fieldsMap.get(groupName); if (fields == null) { fields = new
			 * ArrayList<AttrDef>(); fieldsMap.put(groupName, fields); }
			 * fields.add(attrDef);
			 */
			Collections.sort(attributes, new Comparator<AttrDef>()
			{

				@Override
				public int compare(AttrDef arg0, AttrDef arg1)
				{
					return arg0.seq - arg1.seq;
				}

			});
		}
	}

	private String name;

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getDisplayName()
	{
		return displayName;
	}

	public void setDisplayName(String displayName)
	{
		this.displayName = displayName;
	}

	public List<AttrDef> getAttributes()
	{
		return attributes;
	}

	public void setAttributes(List<AttrDef> attributes)
	{
		this.attributes = attributes;
	}

	private String displayName;
	private List<AttrDef> attributes = new ArrayList<AttrDef>();
}
