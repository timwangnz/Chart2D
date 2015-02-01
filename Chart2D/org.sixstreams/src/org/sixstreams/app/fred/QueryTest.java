package org.sixstreams.app.fred;

import org.sixstreams.search.SearchException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;

public class QueryTest
{
	  static PersistenceManager pm = new PersistenceManager();

	  public static void main(String[] args)
	  {
	    try
		{
	    	SearchHits hit = pm.search("*", TimeSeries.class);
	    	System.err.println(hit.getHitsMetaData().getHits());
		}
		catch (SearchException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	  }

}
