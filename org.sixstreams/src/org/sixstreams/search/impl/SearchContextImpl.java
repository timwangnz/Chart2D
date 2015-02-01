package org.sixstreams.search.impl;

import java.sql.Connection;
import java.util.logging.Logger;

import org.sixstreams.search.AbstractDefaultContext;
import org.sixstreams.search.util.Cryptor;
import org.sixstreams.social.Person;

public class SearchContextImpl extends AbstractDefaultContext
{
	protected static Logger sLogger = Logger.getLogger(SearchContextImpl.class.getName());

	protected Connection connection;
	private String userName = null;
	private Person user;
	private Cryptor cryptor;
	private String appId;
	private String appKey;


	/**
	 * @inheritDoc
	 */
	public String getUserName()
	{
		if (userName == null || userName.length() == 0)
		{

		}
		return userName;
	}

	public void setUserName(String userName)
	{
		this.userName = userName;
	}


	
	public String getAppId()
	{
		return appId;
	}

	public void setAppId(String appId)
	{
		this.appId = appId;
	}

	public String getAppKey()
	{
		return appKey;
	}

	public void setAppKey(String appKey)
	{
		this.appKey = appKey;
	}
	
	public Person getUser()
	{
		return user;
	}

	public void setUser(Person user)
	{
		this.user = user;
	}

	@Override
	public Cryptor getCryptor()
	{
		if (cryptor == null)
		{
			cryptor = new Cryptor(appKey);
		}
		return cryptor;
	}
}
