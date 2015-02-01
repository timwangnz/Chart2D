package org.sixstreams.search.util;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * Class util for loading classes, initializing object etc.
 */
public class ClassUtil
{
	public static URL getResourceUrl(String resourceName)
	{
		return Thread.currentThread().getContextClassLoader().getResource(resourceName);
	}

	// update an object with attribute from new

	public static void patch(Object oldObject, Object newObject)
	{
		if (oldObject.getClass().equals(newObject.getClass()))
		{
			BeanInfo beanInfo;
			try
			{
				beanInfo = Introspector.getBeanInfo(oldObject.getClass());
			}
			catch (IntrospectionException e1)
			{
				// TODO Auto-generated catch block
				e1.printStackTrace();
				return;
			}
			
			List<Field> fields = ClassUtil.getAllFields(oldObject.getClass());
			for (Field field : fields)
			{
				if (!field.getName().equals("id"))
				{
					try
					{
						for (PropertyDescriptor pd : beanInfo.getPropertyDescriptors())
						{
							if (pd.getName().equals(field.getName()))
							{
								if (pd.getReadMethod() != null && pd.getWriteMethod() != null)
								{
									Object value = pd.getReadMethod().invoke(newObject, new Object[]
									{});
									if (value != null)
									{
										pd.getWriteMethod().invoke(oldObject, new Object[]
										{
											value
										});
									}
								}
							}
						}
					}
					catch (Exception e)
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					}

				}
			}
		}
		else
		{
			throw new RuntimeException("Can not patch objects of different types " + oldObject.getClass() + " " + newObject.getClass());
		}
	}

	public static List<Field> getAllFields(Class<?> clazz)
	{
		List<Field> mergedFields = new ArrayList<Field>();
		while (clazz != null)
		{
			for (Field field : clazz.getDeclaredFields())
			{
				boolean existing = false;
				for (Field existingField : mergedFields)
				{
					if (existingField.getName().equals(field.getName()))
					{
						existing = true;
					}
				}
				if (!existing)
				{
					mergedFields.add(field);
				}
			}
			clazz = clazz.getSuperclass();
		}
		return mergedFields;
	}

	public static Object create(String className)
	{
		if (className == null || className.length() == 0)
		{
			return null;
		}
		Class<?> clazz = getClass(className);
		if (clazz == null)
		{
			return null;
		}
		try
		{
			return clazz.newInstance();
		}
		catch (Exception iae)
		{
			//iae.printStackTrace();
		}

		return null;
	}

	public static Class<?> getClass(String className)
	{

		if (className == null || className.length() == 0)
		{
			return null;
		}

		try
		{
			return Thread.currentThread().getContextClassLoader().loadClass(className);
		}
		catch (Throwable iae)
		{
			//iae.printStackTrace();
		}
		return null;
	}
}
