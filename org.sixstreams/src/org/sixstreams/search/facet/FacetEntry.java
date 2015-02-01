package org.sixstreams.search.facet;

import java.io.Serializable;

import org.sixstreams.search.res.DefaultBundle;

public class FacetEntry implements Serializable
{
	// keep it here for serialization
	private String displayValue;
	private transient String attrDisplayName;
	private transient String attrName;
	private String value;
	private transient Facet facet;
	private int count;

	/**
	 * Constructor for FacetEntry
	 */
	public FacetEntry(Facet facet, String attrName, String value, int count)
	{
		this.attrName = attrName;
		this.facet = facet;
		this.value = value;
		this.count = count;
		this.setDisplayValue(this.getDisplayValue());
		this.setAttrDisplayName(DefaultBundle.getResource(this, attrName));
	}

	public String getFacetName()
	{
		return facet.getName();
	}

	public String getAttrName()
	{
		return attrName;
	}

	/**
	 * Gets the value of the entry.
	 * 
	 * @return String
	 */
	public String getValue()
	{
		return this.value;
	}

	/**
	 * Gets the facet that the entry belongs to.
	 * 
	 * @return
	 */
	public Facet getFacet()
	{
		return this.facet;
	}

	/**
	 * Sets the number of documents that match the value of the entry.
	 * 
	 * @param count
	 */
	public void setCount(int count)
	{
		this.count = count;
	}

	/**
	 * Gets the number of documents that match the value of the entry.
	 * 
	 * @return int
	 */
	public int getCount()
	{
		return count;
	}

	public String toString()
	{
		return this.getDisplayValue();
	}

	public String getDisplayValue()
	{
		return displayValue;
	}

	public void setDisplayValue(String displayValue)
	{
		this.displayValue = displayValue;
	}

	public void setAttrDisplayName(String attrDisplayName)
	{
		this.attrDisplayName = attrDisplayName;
	}

	public String getAttrDisplayName()
	{
		return attrDisplayName;
	}

}
