package org.sixstreams.social;

import org.sixstreams.rest.Auditable;
import org.sixstreams.rest.IdObject;
import org.sixstreams.search.SearchContext;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.util.ContextFactory;

/**
 * This class is to be subclassed for actions that link two resources, e.g.
 * like, follow, friendWith etc.
 * 
 * @author anpwang
 * 
 */
@Searchable(title = "authorName")
public abstract class SocialAction extends IdObject implements Auditable
{
	private static final String ANONYMOUS = "anonymous";
	protected static final String ABOUT_ID = "aboutId";
	protected static final String AUTHOR_ID = "authorId";
	protected static final String AURTHOR_NAME = "authorName";
	
	private String aboutId;
	private String aboutType;

	// json that client can sent and interpret them selves. we just store them
	private String rawjson;
	// enough to display witout pull the real thing
	private String aboutName;
	private String aboutUrl;

	// display
	private String title;
	// display
	private String authorName;
	// redirect
	private String authorId;
	// display
	private String authorUrl;

	public SocialAction()
	{
		// this will get current user profile for the creating part,
		// so the client does
		// not need to provide that
		//
		SearchContext ctx = ContextFactory.getSearchContext();
		Person person = ctx.getUser();
		//
		// this would be not be a correct value when get is called
		// but should be overridden from db
		// client could set these values and those will be
		// used if set in the json payload
		//
		if (person != null)
		{
			 
			this.title = person.getSolutation();
			this.authorName = person.getFirstName() + " " + person.getLastName();
			this.authorId = person.getId();
			this.authorUrl = person.getImageUrl();
		}
		else
		{
			this.authorName = ANONYMOUS;
			this.authorId = "";
			this.authorUrl = null;
		}
	}

	public String getTitle()
	{
		return title;
	}

	public void setAuthorTitle(String title)
	{
		this.title = title;
	}

	public void setAuthorName(String authorName)
	{
		this.authorName = authorName;
	}

	public String getAuthorName()
	{
		return authorName;
	}

	public void setAuthorId(String authorId)
	{
		this.authorId = authorId;
	}

	public String getAuthorId()
	{
		return authorId;
	}

	public String getContent()
	{
		return toString();
	}

	public void setAboutId(String aboutId)
	{
		this.aboutId = aboutId;
	}

	public String getAboutId()
	{
		return aboutId;
	}

	public void setAboutType(String aboutType)
	{
		this.aboutType = aboutType;
	}

	public String getAboutType()
	{
		return aboutType;
	}

	public String getAuthorUrl()
	{
		return authorUrl;
	}

	public void setAuthorUrl(String authorUrl)
	{
		this.authorUrl = authorUrl;
	}

	public String getAboutName()
	{
		return aboutName;
	}

	public void setAboutName(String aboutName)
	{
		this.aboutName = aboutName;
	}

	public String getAboutUrl()
	{
		return aboutUrl;
	}

	public void setAboutUrl(String aboutUrl)
	{
		this.aboutUrl = aboutUrl;
	}

	public String getRawjson()
	{
		return rawjson;
	}

	public void setRawjson(String rawjson)
	{
		this.rawjson = rawjson;
	}

	/**
	 * returns a verb that reflects that action, e.g. like, follow, make
	 */
	public abstract String getVerb();
	
	//
	//this method is called just before the action is inserted into the db
	//by default, it 
	public abstract void preCreate();

	/**
	 * This method is called once an action is saved, it allows you to update
	 * related objects. For example, you might want to update number of
	 * followers in the target object etc.
	 */
	public abstract void onCreate();
	public abstract void onDelete();

	public String toString()
	{
		return this.aboutName + " " + this.getVerb() + " " + this.getAuthorName();
	}
}