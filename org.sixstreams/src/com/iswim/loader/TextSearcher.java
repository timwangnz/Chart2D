package com.iswim.loader;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.QueryMetaData;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.SearchableObject;
import org.sixstreams.search.query.QueryMetaDataImpl;

import com.iswim.model.BestTime;
import com.iswim.model.Meet;
import com.iswim.model.MeetFile;
import com.iswim.model.Race;
import com.iswim.model.Swimmer;

public class TextSearcher
{

	PersistenceManager pm = new PersistenceManager();
	public void done()
	{
		pm.close();
	}

	
	public SearchHits getRaces(String query, int page, int pageSize)
	{
		try
		{
			pm.setStart(page);
			pm.setPageSize(pageSize);
			return pm.search(query, Race.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}
	
	public MeetFile getMeetFile(String meetName)
	{
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put("name", "\"" + meetName + "\"");
		try
		{
			List<MeetFile> meetFiles = pm.query(filters, MeetFile.class);
			if (meetFiles.size() == 0)
			{
				return null;
			}
			return (MeetFile) meetFiles.get(0);
		}
		catch (SearchException e)
		{
			throw new RuntimeException("Failed to get swimmer of name " + meetName, e);
		}
	}
	public <T>List<T> getObjects(String query, Class<T> clazz, int page, int pageSize)
	{
		try
		{
			return pm.query(query, null, clazz, page, pageSize);
		}
		catch (SearchException e)
		{
			throw new RuntimeException("Failed to get objects of type " + clazz, e);
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
	
	
	public Swimmer getSwimmer(String name)
	{
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put("name", "\"" + name + "\"");
		try
		{
			List<Swimmer> swimmers = pm.query(filters, Swimmer.class);
			if (swimmers.size() == 0)
			{
				return null;
			}
			return (Swimmer) swimmers.get(0);
		}
		catch (SearchException e)
		{
			throw new RuntimeException("Failed to get swimmer of name " + name, e);
		}
	}

	public SearchHits getRaces(Map<String, Object> attrfilters, String query, int offset, int pageSize)
	{
		long startAt = System.currentTimeMillis();
		try
		{
			SearchableObject so = PersistenceManager.getSearchableObject(-1L, Race.class);
			QueryMetaDataImpl qmd = pm.getQmd(attrfilters, so);
			qmd.setQueryString(query);
			qmd.enableFacets(true);
			qmd.setOffset(offset);
			qmd.setOrderBy("time", QueryMetaData.ASC);
			qmd.setPageSize(pageSize);
			return pm.search(qmd, so);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
		finally
		{
			System.err.println("Time spent " + (System.currentTimeMillis() - startAt));
		}
	}
	public SearchHits getSwimmersOfTeam(String team, int offset, int pageSize)
	{
		try
		{
			pm.setStart(offset);
			pm.setPageSize(pageSize);
			Map<String, Object> filters = new HashMap<String, Object>();
			filters.put("club", "\"" + team + "\"");
			return pm.search(filters, Swimmer.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}
	public SearchHits getSwimmers(String query, int offset, int limit)
	{

		try
		{
			pm.setStart(offset);
			pm.setPageSize(limit);
			return pm.search(query, Swimmer.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}

	public SearchHits getMeetRaces(String meetName, Map<String, Object> attrfilters, int offset, int limit)
	{
		long startAt = System.currentTimeMillis();
		Map<String, Object> filters = new HashMap<String, Object>(attrfilters);
		filters.put("meet", "\"" + meetName + "\"");
		try
		{
			SearchableObject so = PersistenceManager.getSearchableObject(-1L, Race.class);
			QueryMetaDataImpl qmd = pm.getQmd(filters, so);
			qmd.enableFacets(true);
			qmd.setOffset(offset);
			qmd.setOrderBy("time", QueryMetaData.ASC);
			qmd.setPageSize(limit);
			return pm.search(qmd, so);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
		finally
		{
			System.err.println("Time spent " + (System.currentTimeMillis() - startAt));
		}
	}
	
	public SearchHits getTopRaces(Map<String, Object> attrfilters, int offset, int limit)
	{
		long startAt = System.currentTimeMillis();
		Map<String, Object> filters = new HashMap<String, Object>(attrfilters);
		try
		{
			SearchableObject so = PersistenceManager.getSearchableObject(-1L, Race.class);
			QueryMetaDataImpl qmd = pm.getQmd(filters, so);
			qmd.enableFacets(true);
			qmd.setOffset(offset);
			qmd.setOrderBy("time", QueryMetaData.ASC);
			qmd.setPageSize(limit);
			return pm.search(qmd, so);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
		finally
		{
			System.err.println("Time spent " + (System.currentTimeMillis() - startAt));
		}
	}
	
	public SearchHits getRacesOfSwimmer(String swimmerName, int offset, int limit)
	{
		try
		{
			Map<String, Object> filters = new HashMap<String, Object>();
			filters.put("swimmerId", swimmerName);
			SearchableObject so = PersistenceManager.getSearchableObject(-1L, Race.class);
			QueryMetaDataImpl qmd = pm.getQmd(filters, so);
			
			qmd.setOffset(offset);
			qmd.setOrderBy("time", QueryMetaData.ASC);
			qmd.setPageSize(limit);
		
			return pm.search(qmd, Race.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}
	
	public SearchHits getMeetRaces(String meetName, int offset, int limit)
	{
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put("meet", meetName);
		PersistenceManager pm = new PersistenceManager();
		try
		{
			pm.setStart(offset);
			pm.setPageSize(limit);
			
			return pm.search(filters, Race.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}

	public SearchHits getMeets(String query, int offset, int limit)
	{
		try
		{
			pm.setStart(offset);
			pm.setPageSize(limit);
			return pm.search(query, Meet.class);
		}
		catch (SearchException e)
		{
			e.printStackTrace();
			return null;
		}
	}

	public SearchHits getBestTimesForSwimmerWithFilters(String name, Map<String, Object> filters)
	{
		filters.put("swimmerId", "\"" + name + "\"");		try
		{
			return pm.search(filters, BestTime.class);
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	public SearchHits getBestTimeWithFilters(Map<String, Object> filters)
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			return pm.search(filters, BestTime.class);
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}

	Map<String, List<BestTime>> besttimes = new HashMap<String, List<BestTime>>();
	public List<BestTime> getBestTimesForSwimmer(String name)
	{
		List<BestTime> times = besttimes.get(name);
		
		if (times != null)
		{
			return times;
		}
		
		Map<String, Object> filters = new HashMap<String, Object>();
		
		filters.put("swimmerUSSNo", "\"" + name + "\"");
		PersistenceManager pm = new PersistenceManager();
		try
		{
			times = pm.query(filters, BestTime.class, 0, 10000);
			besttimes.put(name, times);
			return times;
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
			return Collections.emptyList();
		}
	}

}
