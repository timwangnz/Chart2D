package org.sixstreams.search.data.java;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.rest.writers.JSONWriter;
import org.sixstreams.search.Document;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
import org.sixstreams.search.meta.AbstractDocumentDefinition;
import org.sixstreams.search.meta.AttributeDefinition;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.PrimaryKeyUtil;

public class DocumentDefinitionImpl extends AbstractDocumentDefinition
{
	protected static Logger sLogger = Logger.getLogger(DocumentDefinitionImpl.class.getName());
	private Class<?> clazz;
	private transient BeanInfo beanInfo;

	protected DocumentDefinitionImpl()
	{
		super("NotDefined");
	}

	public DocumentDefinitionImpl(SearchableDataObject so, Class<?> clazz)
	{
		super(clazz.getName());
		searchableObject = so;
		this.clazz = clazz;
		init();
	}

	// only for internal use
	void init()
	{
		try
		{
			beanInfo = Introspector.getBeanInfo(clazz);
			for (Field field : ClassUtil.getAllFields(clazz))
			{
				boolean isTransient = Modifier.isTransient(field.getModifiers());
				if (isTransient)
				{
					continue;
				}
				PropertyDescriptor propertyDescritpor = null;
				for (PropertyDescriptor pd : beanInfo.getPropertyDescriptors())
				{
					if (pd.getName().equals(field.getName()))
					{
						if (pd.getReadMethod() != null && pd.getWriteMethod() != null)
						{
							propertyDescritpor = pd;
						}
					}
				}
				if (propertyDescritpor != null)
				{
					ObjectAttrDefinitionImpl fd = new ObjectAttrDefinitionImpl(field.getName(), propertyDescritpor);
					SearchableAttribute attrNotation = field.getAnnotation(SearchableAttribute.class);
					if (attrNotation != null)
					{
						assignAttributeDef(attrNotation, fd);
						if (attrNotation.facetName().length() != 0)
						{
							fd.setFacetAttr(true);
							((SearchableDataObject) searchableObject).addSearchFacetDef(attrNotation.facetName(), attrNotation.facetPath(), attrNotation.isRangeSearchEnabled());
						}
					}
					else
					{
						fd.setDisplayable(true);
						fd.setStored(true);
						fd.setIndexed(true);
					}
					this.addAttrDef(fd);
				}
			}
		}
		catch (IntrospectionException e)
		{
			e.printStackTrace();
		}

		for (Annotation annotation : clazz.getAnnotations())
		{
			if (annotation instanceof Searchable)
			{
				String title = ((Searchable) annotation).title();
				searchableObject.setTitle(title);
				String keywords = ((Searchable) annotation).keywords();
				searchableObject.setKeywords(keywords);
				String plugin = ((Searchable) annotation).plugin();
				searchableObject.setPlugInName(plugin);
				String content = ((Searchable) annotation).content();
				searchableObject.setContent(content);
				searchableObject.setSecure(((Searchable) annotation).isSecure());
			}
		}
	}

	private void assignAttributeDef(SearchableAttribute attrNotation, ObjectAttrDefinitionImpl fd)
	{
		fd.setBoost(attrNotation.boost());
		fd.setSecure(attrNotation.isSecure());
		fd.setEncrypted(attrNotation.isEncrypted());
		fd.setStored(attrNotation.isStored());
		fd.setIndexed(attrNotation.isIndexed());
		fd.setDisplayable(attrNotation.isDisplayable());
		fd.setSortable(attrNotation.isSortable());
		fd.setSeqneuce(attrNotation.sequence());
		fd.setPrimaryKey(attrNotation.isKey());
		fd.setRequired(attrNotation.isRequired());
		fd.setLovDef(attrNotation.lov());
		fd.setForeignKey(attrNotation.foreignKey());
		if (attrNotation.aggregateFunction().length() > 0)
		{
			fd.setAggregateFunction(attrNotation.aggregateFunction());
		}

		if (attrNotation.readableType().length() > 0)
		{
			fd.setReadableType(attrNotation.readableType());
		}
		if (attrNotation.convertor().length() > 0)
		{
			fd.setConvertor(attrNotation.convertor());
		}
		if (attrNotation.groupName().length() > 0)
		{
			fd.setGroupName(attrNotation.groupName());
		}
	}

	public void assign(Document doc, Object valueObject)
	{
		for (AttributeDefinition fd : getAttrDefs())
		{
			Object value = getValue(valueObject, (ObjectAttrDefinitionImpl) fd);
			doc.setAttrValue(fd.getName(), value);
		}
	}

	public void assign(Object valueObject, Map<String, Object> doc)
	{
		for (AttributeDefinition fd : getAttrDefs())
		{
			Object value = doc.get(fd.getName());
			if (fd.isStored() || fd.isPrimaryKey())
			{
				if (value != null)
				{
					setValue(valueObject, (ObjectAttrDefinitionImpl) fd, value);
				}
			}
		}
	}

	public void assign(Object valueObject, Document doc, List<String> partialRules)
	{
		for (AttributeDefinition fd : getAttrDefs())
		{
			if (partialRules == null || partialRules.contains(fd.getName()) || fd.isPrimaryKey())
			{
				Object value = doc.getAttrValue(fd.getName());
				if (fd.isStored() || fd.isPrimaryKey())
				{
					setValue(valueObject, (ObjectAttrDefinitionImpl) fd, value);
				}
			}
		}
	}

	public void assign(Object valueObject, Document doc)
	{
		assign(valueObject, doc, null);
	}

	public void generatePrimaryKey(Object valueObject)
	{
		for (AttributeDefinition fd : getAttrDefs())
		{
			if (fd.isPrimaryKey())
			{
				setValue(valueObject, (ObjectAttrDefinitionImpl) fd, PrimaryKeyUtil.generateKey(fd));
			}
		}
	}

	public void assign(Map<String, Object> attrValues, Object object)
	{
		for (String key : attrValues.keySet())
		{
			setAttrValueFor(object, key, attrValues.get(key));
		}
	}

	public void setAttrValueFor(Object obj, String attrName, Object value)
	{
		ObjectAttrDefinitionImpl attrDef = (ObjectAttrDefinitionImpl) getAttributeDef(attrName);
		if (attrDef == null)
		{
			sLogger.log(Level.SEVERE, "Failed to set value " + obj + " set " + attrName + ":" + value + " type of " + value.getClass().getName());
			return;
		}
		setValue(obj, attrDef, value);
	}

	public void setValue(Object obj, ObjectAttrDefinitionImpl attrDef, Object value)
	{
		try
		{
			Method method = attrDef.getPropertyDescriptor().getWriteMethod();
			if (method != null)
			{
				if (value == null && method.getParameterTypes()[0].isPrimitive())
				{
					return; // we dont set primtive value for null object
				}
				method.invoke(obj, new Object[]
				{
					coerseObject(method.getParameterTypes()[0], value, attrDef)
				});

			}
			else
			{
				sLogger.warning("No Setter is available for this attribute " + attrDef.getName());
			}
		}
		catch (Exception e)
		{
			if (value != null)
			{
				sLogger.log(Level.SEVERE, "Failed to set value " + obj + " set " + attrDef.getName() + ":" + value + " type of " + value.getClass().getName(), e);
			}
		}
	}

	Object coerseObject(Class<?> clazz, Object object, ObjectAttrDefinitionImpl attrDef)
	{
		if (object == null)
		{
			return object;
		}

		if (clazz.isInstance(object))
		{
			return object;
		}

		if (clazz.equals(StringBuffer.class))
		{
			return new StringBuffer(object.toString());
		}

		if (clazz.equals(String.class))
		{
			return object.toString();
		}

		if (object instanceof List && clazz.isArray())
		{
			if (clazz.getComponentType().equals(String.class))
			{
				return ((List<?>) object).toArray(new String[]
				{});
			}
			else
			{
				throw new RuntimeException("Unsupported data type for Array " + clazz);
			}
		}

		if (object instanceof Boolean)
		{
			if (clazz.equals(Boolean.class) || clazz.getName().equals("boolean"))
			{
				return ((Boolean) object).booleanValue();
			}
		}

		if (object instanceof Number)
		{
			if (clazz.equals(Long.class) || clazz.getName().equals("long"))
			{
				return ((Number) object).longValue();
			}
			else if (clazz.equals(Double.class) || clazz.getName().equals("double"))
			{
				return ((Number) object).doubleValue();
			}
			else if (clazz.equals(Float.class) || clazz.getName().equals("float"))
			{
				return ((Number) object).floatValue();
			}
			else if (clazz.equals(Integer.class) || clazz.getName().equals("int"))
			{
				return ((Number) object).intValue();
			}
			else
			{
				return object;
			}
		}

		if (object instanceof String && object.toString().length() > 0)
		{
			if (clazz.getName().equals("long"))
			{
				return Long.valueOf("" + object);
			}
			else if (clazz.getName().equals("double"))
			{
				return Double.valueOf("" + object);
			}
			else if (clazz.getName().equals("int"))
			{
				return Integer.valueOf("" + object);
			}
			else if (clazz.getName().equals("boolean"))
			{
				return Boolean.valueOf("" + object);
			}
			else if (clazz.getName().equals("float"))
			{
				return Float.valueOf("" + object);
			}
			else if (clazz.equals(String.class))
			{
				return object;
			}
			else if (clazz.equals(Date.class))
			{
				return stringToDate(object.toString(), attrDef);
			}
			else
			{
				JSONWriter writer = new JSONWriter();
				return writer.toObject(object.toString(), clazz);
			}
		}

		if (object instanceof Date)
		{
			return sdf.format((Date) object);
		}
		return object;
	}

	private Object getValue(Object obj, ObjectAttrDefinitionImpl field)
	{
		try
		{
			Method m = field.getPropertyDescriptor().getReadMethod();
			return m.invoke(obj, new Object[]
			{});
		}
		catch (Exception e)
		{
			sLogger.log(Level.SEVERE, "Failed to get value for " + obj.getClass().getName() + "." + field.getName(), e);
		}
		return null;
	}

	static SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");

	private static Date stringToDate(String stringValue, ObjectAttrDefinitionImpl field)
	{
		try
		{
			return sdf.parse(stringValue);
		}
		catch (ParseException e)
		{
			sLogger.log(Level.SEVERE, "Failed to convert to Date " + stringValue + "." + field.getName(), e);
			return null;
		}
	}

	public void setClazz(Class<?> clazz)
	{
		this.clazz = clazz;
		setName(clazz.getName());
	}

	public Class<?> getClazz()
	{
		return clazz;
	}
}
