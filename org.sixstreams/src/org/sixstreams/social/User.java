package org.sixstreams.social;

import org.sixstreams.rest.IdObject;
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

@Searchable(title = "username", isSecure=true)
public class User extends IdObject
{
	@SearchableAttribute(isEncrypted=true)
	private String password;

	private String username;
	private String hintQ;
	private String hintA;
	private String email;
	
	@SearchableAttribute(isStored = false, isIndexed = false)
	private Person profile;
	//this can be sixstreams, facebook, google, or anyother oauth system
	private String authSource = "sixstreams.com";
	
	public String getAuthSource()
	{
		return authSource;
	}

	public void setAuthSource(String authSource)
	{
		this.authSource = authSource;
	}

	public User()
	{
		super();
	}
	
	public String getPassword()
	{
		return password;
	}
	public void setPassword(String password)
	{
		this.password = password;
	}
	public String getUsername()
	{
		return username;
	}
	public void setUsername(String username)
	{
		this.username = username;
	}
	public String getHintQ()
	{
		return hintQ;
	}
	public void setHintQ(String hintQ)
	{
		this.hintQ = hintQ;
	}
	public String getHintA()
	{
		return hintA;
	}
	public void setHintA(String hintA)
	{
		this.hintA = hintA;
	}
	public String getEmail()
	{
		return email;
	}
	public void setEmail(String email)
	{
		this.email = email;
	}
	
	public Person getProfile()
	{
		 return profile;
	}

	public void setProfile(Person profile)
	{
		this.profile = profile;
	}
}
