package org.twc.model;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.sixstreams.Constants;
import org.sixstreams.app.data.Company;
import org.sixstreams.search.AttributeFilter;
import org.sixstreams.search.IndexedDocument;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.java.annotations.Searchable;

import com.google.gson.Gson;

@Searchable(title = "name", isSecure = false)
public class Roaster extends Company
{
	private String notes;
	private String beans;
	private String hours;

	private String recommendedBy;

	private String area;
	private String ownerId;

	private String status;

	public static void query(String query)
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			List<AttributeFilter> filters = new ArrayList<AttributeFilter>();

			AttributeFilter distanceFilter = new AttributeFilter("latitude", "NUMBER", new Float(34.0), Constants.OPERATOR_GT);
			filters.add(distanceFilter);
			distanceFilter = new AttributeFilter("longitude", "NUMBER", new Float(-119.0), new Float(-118.0));
			filters.add(distanceFilter);

			SearchHits hits = pm.search(query, filters, Roaster.class, 1, 50, "latitude");

			for (IndexedDocument doc : hits.getIndexedDocuments())
			{
				System.err.println(doc.getTitle() + " " + doc.getAttrValue("latitude") + " " + doc.getAttrValue("longitude"));
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			pm.close();
		}
	}
	 
	
	public static boolean isInitialized()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			SearchHits hits = pm.search("*", Roaster.class);
			return hits.getCount() > 0;
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			pm.close();
		}
		return false;
	}

	public static void init()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			Gson gson = new Gson();

			InputStream inputStream = Roaster.class.getResourceAsStream("./Roasters.json");
			InputStreamReader isr = new InputStreamReader(inputStream);
			Roaster[] roasters = gson.fromJson(isr, Roaster[].class);
			for (Roaster roaster : roasters)
			{
				roaster.setDateCreated(new Date());
				roaster.setCreatedBy("seed");
				pm.update(roaster);
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}


	public String getStatus()
	{
		return status;
	}

	public void setStatus(String status)
	{
		this.status = status;
	}

	public String getNotes()
	{
		return notes;
	}

	public void setNotes(String notes)
	{
		this.notes = notes;
	}

	public String getBeans()
	{
		return beans;
	}

	public void setBeans(String beans)
	{
		this.beans = beans;
	}

	public String getHours()
	{
		return hours;
	}

	public void setHours(String hours)
	{
		this.hours = hours;
	}

	public String getOwnerId()
	{
		return ownerId;
	}

	public void setOwnerId(String ownerId)
	{
		this.ownerId = ownerId;
	}

	public String getArea()
	{
		return area;
	}

	public void setArea(String area)
	{
		this.area = area;
	}

	public String toString()
	{
		return this.getId() + " " + this.getName() + " " + this.beans;
	}

	public String getRecommendedBy()
	{
		return recommendedBy;
	}

	public void setRecommendedBy(String recommendedBy)
	{
		this.recommendedBy = recommendedBy;
	}
}
