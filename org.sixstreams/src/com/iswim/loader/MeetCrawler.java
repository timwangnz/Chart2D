package com.iswim.loader;

import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.IndexingException;
import org.sixstreams.search.data.PersistenceManager;

import com.iswim.model.BestTime;
import com.iswim.model.MeetFile;
import com.iswim.model.Race;
import com.iswim.model.Swimmer;
import com.iswim.model.Team;


public class MeetCrawler extends CrawlSD3
{
	
	String location = "/Users/anpwang/pacswim/meets/";
	boolean download = false;
	
	@Override
	int process(int max)
	{
		if (!download)
		{
			return super.process(max);
		}
		else
		{
			return download(max);
		}
	}

	int download(int max)
	{
		int crawled = 0;
		for (int i = 0; i < sd3List.size(); i++)
		{
			String sd3url = (String) sd3List.get(i);
			try
			{
				if (crawled >= max)
				{
					return crawled;
				}
				long time = System.currentTimeMillis();
				if (downloadZipFile(sd3url))
				{
					crawled++;
					System.err.println("Downloaded " + sd3url + " in " + (System.currentTimeMillis() - time));
				}
			}
			catch (Throwable e)
			{
				e.printStackTrace();
			}
		}
		return crawled;
	}

	boolean downloadZipFile(String zipname) throws Exception
	{
		return FileUtil.saveFile(new URL(zipname), location, zipname, false);
	}
	
	boolean isMeetDownloaded(String url)
	{
		return false;
	}
	
	protected void saveMeetFile(String meetName)
	{
		try
		{
			PersistenceManager pm = new PersistenceManager();
			MeetFile meetFile = new MeetFile();
			meetFile.setName(meetName);
			pm.insert(meetFile);
			//
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}


	protected boolean isMeetCrawled(String meetName)
	{
		TextSearcher searcher = new TextSearcher();
		MeetFile meetFile = searcher.getMeetFile(meetName);
		return meetFile != null;
	}
	
	public void save()
	{
		
		int i = 0;
		long timeStarted = System.currentTimeMillis();
		List<Race> batch = new ArrayList<Race>();
		List<BestTime> btBatch = new ArrayList<BestTime>();
		
		for (Swimmer swimmer : meetLoader.getRaces().keySet())
		{
			List<Race> races = meetLoader.getRaces().get(swimmer);
			//
			// swimmer's club goes with race
			// this not work in some cases as a swimmer might represent a
			// different team in a
			// race. but it should work most times
			//

			batch.addAll(races);

			btBatch.addAll(this.besttimesToUpdate(swimmer, races));
			
			i++;
			if (i % 100 == 0)
			{
				sLogger.info(i + " swimmers saved in  " + (System.currentTimeMillis() - timeStarted));
			}
			if (batch.size() > 200)
			{
				try
				{
					PersistenceManager pm = new PersistenceManager();
					long t1 = System.currentTimeMillis();
					pm.insert(batch);
					batch.clear();
					itemsIndexed += 200;
					System.err.println("200 races saved in  " + (System.currentTimeMillis() - t1));
				}
				catch (IndexingException e)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			if (btBatch.size() > 200)
			{
				try
				{
					PersistenceManager pm = new PersistenceManager();
					pm.insert(btBatch);
					btBatch.clear();
					itemsIndexed += 200;
				}
				catch (IndexingException e)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

		}
		if (btBatch.size() > 0)
		{
			try
			{
				PersistenceManager pm = new PersistenceManager();
				pm.insert(btBatch);
				itemsIndexed += btBatch.size();
				btBatch.clear();
			}
			catch (IndexingException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		if (batch.size() > 0)
		{
			try
			{
				PersistenceManager pm = new PersistenceManager();
				pm.insert(batch);
			
				itemsIndexed += batch.size();
				batch.clear();
			}
			catch (IndexingException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		try
		{
			List<Swimmer> swimmers = new ArrayList<Swimmer>(meetLoader.getSwimmers().values());
			PersistenceManager pm = new PersistenceManager();
			pm.insert(swimmers);

			itemsIndexed += swimmers.size();
			List<Team> teams = new ArrayList<Team>(meetLoader.getTeams().values());
			pm.insert(teams);
			pm.insert(meetLoader.getMeet());
		}
		catch (IndexingException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.err.println("persists " + meetLoader.getSwimmers().size() + " swimmers and " + meetLoader.getTeams().size() + " teams " + " total " + itemsIndexed + " "
						+ (System.currentTimeMillis() - startedAt));
	}

	public List<BestTime> besttimesToUpdate(Swimmer swimmer, List<Race> races)
	{
		if (races.size() == 0)
		{
			return Collections.emptyList();
		}
		
		TextSearcher searcher = new TextSearcher();
		//
		// all the races for this swimmer would be for the same age group
		// as this is done per meet
		//
		List<BestTime> besttimes = searcher.getBestTimesForSwimmer(swimmer.getSwimmerUSSNo());
		
		List<BestTime> besttimes2Update = new ArrayList<BestTime>();

		for (Race race : races)
		{
			BestTime bt = null;
			for (BestTime besttime : besttimes)
			{
				if (equals(race, besttime))
				{
					bt = besttime;
					break;
				}
			}

			if (bt == null)// not found in best-time table
			{
				bt = new BestTime();
				bt.setTime(1000000000000000000L);
				besttimes.add(bt);
			}

			if (bt.getTime() > race.getTime())
			{
				bt.assign(race);
				if (!race.getFirstName().equals(swimmer.getFirstName()) || !race.getLastName().equals(swimmer.getLastName()))
				{
					System.err.println(swimmer.getSwimmerUSSNo() + " " + swimmer.getFirstName() + " " + swimmer.getLastName() + " is different " + race);
				}
				else
				{
					besttimes2Update.add(bt);
				}
			}
		}
		return besttimes2Update;
	}
	static Map<String, Map<String, List<BestTime>>> teamCache = new HashMap<String, Map<String, List<BestTime>>>();
	static long itemsIndexed = 0;
	static long startedAt = System.currentTimeMillis();

}
