package org.sixstreams.social;

import org.sixstreams.Constants;
import org.sixstreams.rest.RestfulException;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.QueryBuilder;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.util.ClassUtil;
import org.sixstreams.search.util.ContextFactory;

/**
 * This is one way connection, you can follow a resource of any social type,
 * person, comment, notes, etc. to get what you follow use select resourceId,
 * resourceName, resourceUrl from socialFollow where createdBy=me and
 * resourceType=typeOf resource to get followed by, select authorId, authorName,
 * authorUrl
 **/

@Searchable(title = "resourceName")
public class SocialFollow extends SocialAction
{
	private static String VERB = "follow";
	public String getVerb()
	{
		return VERB;
	}

	//
	// TODO
	// lifecycle triggers for this action
	// we should do this better
	//
	private transient Socialable object = null;
	private transient Person person = null;

	// this method is called just before the action is inserted into the db
	// by default, it
	public void preCreate()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			object = (Socialable) pm.getObjectById(this.getAboutId(), ClassUtil.getClass(this.getAboutType()));
			person = ContextFactory.getSearchContext().getUser();
			QueryBuilder qb = new QueryBuilder();
			
			qb.setObjectType(getClass().getName()).setLimit(1)
				.addFilter(AUTHOR_ID, person.getId(), Constants.STRING, Constants.SEARCH_OPERATOR_EQ).
			   addFilter(ABOUT_ID, object.getId(), Constants.STRING, Constants.SEARCH_OPERATOR_EQ);
		
			SearchHits hits = pm.search(qb.create(), this.getClass());
			if (hits.getCount() > 0)
			{
				throw new RestfulException(401, "You are already following " + object, VERB);
			}
		}
		catch (RestfulException e)
		{
			throw e;
		}
		catch (Exception e)
		{
			e.printStackTrace();
			throw new RestfulException(401, "Failedt to " + this.getVerb() + "\n" + e.getLocalizedMessage(), VERB);
		}
	}

	/**
	 * This method is called once an action is saved, it allows you to update
	 * related objects. For example, you might want to update number of
	 * followers in the target object etc.
	 */
	public void onCreate()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			object.setFollowers(object.getFollowers() + 1);
			person.setFollowing(person.getFollowing() + 1);
			pm.update(object);
			pm.update(person);
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void onDelete()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			object.setFollowers(object.getFollowers() - 1);
			person.setFollowing(person.getFollowing() - 1);
			pm.update(object);
			pm.update(person);
		}
		catch (Exception e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
