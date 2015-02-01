package org.sixstreams.social;

import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.util.ClassUtil;

@Searchable(title = "resourceName", isSecure = false)
public class Like extends SocialAction
{
	public String getVerb()
	{
		return "like";
	}
	
	public void onDelete()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			Socialable object = (Socialable) pm.getObjectById(this.getAboutId(), ClassUtil.getClass(this.getAboutType()));
			object.setLiked(object.getLiked() - 1);
			pm.update(object);
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}	 
	
	public void onCreate()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			Socialable object = (Socialable) pm.getObjectById(this.getAboutId(), ClassUtil.getClass(this.getAboutType()));
			object.setLiked(object.getLiked() + 1);
			pm.update(object);
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}	 
	
	public void preCreate()
	{
		
	}
}
