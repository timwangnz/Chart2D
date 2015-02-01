package org.sixstreams.search.meta;

import java.io.Serializable;
import java.lang.reflect.Type;

import org.sixstreams.search.SearchContext;
import org.sixstreams.search.util.ContextFactory;

/**
 * Implementation of AttributeDefinition.
 */
public class AttributeDefImpl implements AttributeDefinition, Serializable
{
	private String dataType;
	private String name;
	private String convertor;
	private int sequence = -1;
	private transient DocumentDefinition ownerDocument;
	private String aggregateFunction;
	private String readableType;
	// if this field is stored.
	private boolean stored;
	private boolean indexed;
	private boolean facetAttr;

	private float boost = 1.0f;

	private String foreignKey;

	private boolean primaryKey;
	private boolean encrypted;
	private boolean secure;
	// UI related
	private boolean editable;

	private boolean required;
	private boolean displayable;
	private boolean sortable;
	private boolean list;
	private String listType;
	private String groupName;
	private String lovDef;
	// list of possible values
	private boolean language = false;

	public String getForeignKey()
	{
		return foreignKey;
	}

	public void setForeignKey(String foreignKey)
	{
		this.foreignKey = foreignKey;
	}

	public AttributeDefImpl(String name, String attrType)
	{
		this.name = name;
		dataType = attrType;
	}

	public void setStored(boolean stored)
	{
		this.stored = stored;
	}

	public boolean isStored()
	{
		return stored;
	}

	public void setFacetAttr(boolean facetAttr)
	{
		this.facetAttr = facetAttr;
	}

	public boolean isFacetAttr()
	{
		return facetAttr;
	}

	public void setBoost(float boost)
	{
		this.boost = boost;
	}

	public float getBoost()
	{
		return boost;
	}

	public final String getDisplayName()
	{
		
		return  getName();
	}

	public void setPrimaryKey(boolean primaryKey)
	{
		this.primaryKey = primaryKey;
	}

	public boolean isPrimaryKey()
	{
		return primaryKey;
	}

	public void setDataType(String dataType)
	{
		this.dataType = dataType;
	}

	public String getDataType()
	{
		return dataType == null ? STRING : dataType;
	}

	public Type getType()
	{
		return String.class;
	}

	public boolean isSecure()
	{
		return secure;
	}

	public void setSecure(boolean secure)
	{
		this.secure = secure;
	}

	public void setDocumentDef(DocumentDefinition ownerDocument)
	{
		this.ownerDocument = ownerDocument;
	}

	public DocumentDefinition getDocumentDef()
	{
		return ownerDocument;
	}

	public void setLanguageAttr(boolean isLanguageAttr)
	{
		this.language = isLanguageAttr;
	}

	public boolean isLanguageAttr()
	{
		return language;
	}

	public void setSeqneuce(int sequence)
	{
		this.sequence = sequence;
	}

	public int getSequence()
	{
		return sequence;
	}

	public String toString()
	{
		return getName() + " - " + getDataType() + " " + getBoost() + " " + getSequence();
	}

	public String getGroupName()
	{
		return groupName;
	}

	public void setGroupName(String groupName)
	{
		this.groupName = groupName;
	}

	public void setSortable(boolean sortable)
	{
		this.sortable = sortable;
	}

	public boolean isSortable()
	{
		return sortable;
	}

	public void setDisplayable(boolean displayable)
	{
		this.displayable = displayable;
	}

	public boolean isDisplayable()
	{
		return displayable;
	}

	public void setConvertor(String convertor)
	{
		this.convertor = convertor;
	}

	public String getConvertor()
	{
		return convertor;
	}

	public void setEditable(boolean editable)
	{
		this.editable = editable;
	}

	public boolean isEditable()
	{
		return editable;
	}

	public String getName()
	{
		return name;
	}

	public void setIndexed(boolean indexed)
	{
		this.indexed = indexed;
	}

	public boolean isIndexed()
	{
		return indexed;
	}

	public void setReadableType(String readableType)
	{
		this.readableType = readableType;
	}

	public String getReadableType()
	{
		return readableType;
	}

	public void setAggregateFunction(String aggregateFunction)
	{
		this.aggregateFunction = aggregateFunction;
	}

	public String getAggregateFunction()
	{
		return aggregateFunction;
	}

	public void setList(boolean list)
	{
		this.list = list;
	}

	public boolean isList()
	{
		return list;
	}

	public void setLovDef(String lovDef)
	{
		this.lovDef = lovDef;
	}

	public String getLovDef()
	{
		return lovDef;
	}

	public boolean isRequired()
	{
		return required;
	}

	public void setRequired(boolean required)
	{
		this.required = required;
	}

	public void setEncrypted(boolean encrypted)
	{
		this.encrypted = encrypted;
	}

	@Override
	public boolean isEncrypted()
	{
		// TODO Auto-generated method stub
		return this.encrypted;
	}

	public String getListType()
	{
		return listType;
	}

	public void setListType(String listType)
	{
		this.listType = listType;
	}
}
