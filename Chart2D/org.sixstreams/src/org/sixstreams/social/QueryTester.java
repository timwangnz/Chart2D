package org.sixstreams.social;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;

import com.iswim.model.Race;
import com.iswim.model.Swimmer;

public class QueryTester
{
	static
	{
		Logger.getLogger("").setLevel(Level.SEVERE);
	}
	static long totalCount = 0;
	static long totalObjects = 0;
	static HashMap<IdObject, List<IdObject>> idObjectsCache = new HashMap<IdObject, List<IdObject>>();
	
	static abstract class Task
	{
		abstract void doBatch(Collection<? extends IdObject> objects);
		abstract void doFinish();
	}
	public static void main(String[] args)
	{
		long timestarted = System.currentTimeMillis();
		QueryTester testsuit = new QueryTester();
		
		//testsuit.process("P*", null, Race.class);
		
		testsuit.process("P*", null, Swimmer.class, Race.class, "swimmerUSSNo");
		
		System.err.println("time spent - " + (System.currentTimeMillis() - timestarted));
		/*
		for (IdObject object : idObjectsCache.keySet())
		{
			System.err.println("" +object + " followed by "+ idObjectsCache.get(object).size());
		}
		*/
		System.exit(0);
	}
	
	static class IdObjectTask extends Task
	{
		IdObject object;
		List<IdObject> objects = new ArrayList<IdObject>();
		IdObjectTask(IdObject object)
		{
			this.object = object;
		}
		
		void doBatch(Collection<? extends IdObject> objects)
		{
			this.objects.addAll(objects);
			totalCount+= objects.size();
		}
		void doFinish()
		{
			idObjectsCache.put(object, objects);
			if(totalCount % 100 == 0)
			{
				System.err.println(" " + object + " - " + objects.size() + " total " + totalCount + " " + totalObjects );
			}
		}
	}

	PersistenceManager pm = new PersistenceManager();

	public void list(String query, Map<String, Object> filters, Class<? extends IdObject> clazz, Task task)
	{
		long timestarted = System.currentTimeMillis();
		int i=1;
		int pageSize = 1000;
		
		while(true)
		{
			Collection<? extends IdObject> objects = getObjects(query, filters, clazz, i++, pageSize);
			if (objects.isEmpty())
			{
				break;
			}
			task.doBatch(objects);
		}
		task.doFinish();
		if(totalCount % 100 == 0)
		{
			System.err.println("time spent for " + clazz + " - " + (System.currentTimeMillis() - timestarted));
		}
	}
	
	public <T>List<T> getObjects(String query, Map<String, Object> filters, Class<T> clazz, int page, int pageSize)
	{
		try
		{
			return pm.query(query, filters, clazz, page, pageSize);
		}
		catch (SearchException e)
		{
			throw new RuntimeException("Failed to get objects of type " + clazz, e);
		}
	}
	
	public void process(String query, Map<String, Object> filters, Class<? extends IdObject> clazz)
	{
		list(query, filters, clazz, new Task()
		{
			void doBatch(Collection<? extends IdObject> objects)
			{
				for(IdObject object : objects)
				{
					if(totalObjects % 1000 == 0)
					System.err.println(totalObjects + " " + object);
					totalObjects ++;
				}
			}
			void doFinish()
			{
				//does nothing
			}
		}
		);
	}
	
	public void process(final String query, Map<String, Object> filters, Class<? extends IdObject> clazz, final Class<? extends IdObject> childClass, final String foreignKey)
	{
		list(query, filters, clazz, new Task()
		{
			void doBatch(Collection<? extends IdObject> objects)
			{
				for(IdObject object : objects)
				{
					String id = object.getId();
					Map<String, Object> idFilter = new HashMap<String, Object>();
					idFilter.put(foreignKey, id);
					list(query, idFilter, childClass, new IdObjectTask(object));
					totalObjects ++;
				}
			}
			void doFinish()
			{
				//does nothing
			}
		}
		);
	}
}

