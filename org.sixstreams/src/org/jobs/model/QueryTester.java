package org.jobs.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;

import com.google.gson.Gson;


public class QueryTester
{
	public static void query1()
	{
		String query = "name:\"My Dream Job\"";//"company:(\"Oracle\" OR \"General Hospital\") AND travel:(\"unknown\" OR \"none\") AND category:(\"83\" OR \"93\")";
		PersistenceManager pm = new PersistenceManager();
		try
		{
			System.err.println(AttributeFilter.fromQuery(Resume.class.getName(), query));
			Map<String, Object> filter = new HashMap<String, Object>();
			//filter.put("position", "\"Entry Level\"");
			//filter.put("keywords", "Typing");
			List<Resume> jobs = pm.query(filter, Resume.class);

			Gson gson = new Gson();
			System.err.println(gson.toJson(jobs));
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
		{
			pm.close();
		}
	}
	
	public static void query()
	{
		String query = "*";
		PersistenceManager pm = new PersistenceManager();
		try
		{
			List<Applicant> jobs = pm.query(query, Applicant.class);
			System.err.println("Number of jobs " + jobs.size());
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally
		{
			pm.close();
		}
	}
	
	public static void main(String[] args)
	{
		query();
	}
	public static void jsonTest()
	{
		try
		{
			Resume newJob = new Resume();
			newJob.setName("Test");
			newJob.setKeywords("Developer");
			
			newJob.setSummary("This is a tough job for Oracle");
			
			List<String> skillSet = new ArrayList<String>();
			skillSet.add("Java");
			skillSet.add("Oracle Database");
			skillSet.add("Google Cloud Sersvice");
			newJob.setSkillset(skillSet);
			
			List<Experience> experience = new ArrayList<Experience>();
			
			experience.add(new Experience("Test", "2001", "2002", "Oracle"));
			experience.add(new Experience("Engineer", "2002", "2003", "Google"));
			
			newJob.setExperience(experience);
			
			Gson gson = new Gson();
			
			String jsonString  = gson.toJson(newJob);
			System.err.println(jsonString);
			
			Resume job = gson.fromJson(jsonString, Resume.class);
			System.err.println(job.getSkillset());
			System.err.println(job.getExperience());
			//pm.update(newJob);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

}
