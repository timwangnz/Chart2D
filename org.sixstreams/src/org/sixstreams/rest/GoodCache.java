package org.sixstreams.rest;

import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

import org.sixstreams.social.Activity;
import org.sixstreams.social.Person;
import org.sixstreams.social.User;

public class GoodCache
{
	private static Map<String, GoodCache> caches = new HashMap<String, GoodCache>();
	//TODO, this need a lot  more work
	public void update(Object object)
	{
		if (object instanceof Person)
		{
			if(((Person)object).getUsername() != null)
			{
				this.put(((Person)object).getUsername(), object);
			}
		}
	}
	
	public void delete(Object object)
	{
		if (object instanceof Person)
		{
			this.dummyCache.remove(((Person)object).getUsername());
		}
		if (object instanceof User)
		{
			this.dummyCache.remove(((User)object).getUsername());
		}
	}
	
	public static GoodCache getCache(String objectType)
	{
		GoodCache goodCache = caches.get(objectType);
		if (goodCache == null)
		{
			goodCache = new GoodCache(objectType);
			caches.put(objectType, goodCache);
		}
		return goodCache;
	}
	
	private String cacheType;
	
	public GoodCache(String objectType)
	{
		cacheType = objectType;
	}

	private Map<String, Object> dummyCache = new Hashtable<String, Object>();

	//some kind of policy should be implemented here
	public void put(String key, Object Object)
	{
		dummyCache.put(key, Object);
	}
	public Object get(String key)
	{
		return dummyCache.get(key);
	}

	public String toString()
	{
		return cacheType + " " + dummyCache.size();
	}
	
	//
	//update activities for people who follow this person
	//this should be an async call
	//
	public static void updateActivityFor(Person person, Activity activity)
	{
		// TODO Auto-generated method stub
		
	}
}
