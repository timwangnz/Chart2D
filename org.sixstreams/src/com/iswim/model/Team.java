package com.iswim.model;
 
import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;
 
@Searchable(title="fullName")
public class Team
{ 
	@SearchableAttribute(isKey=true)
	private String teamCode;


	@SearchableAttribute
	private String fullName;

	@SearchableAttribute
	private String shortName;


	@SearchableAttribute
	private String url;

	@SearchableAttribute
	private String headCoach;


	@SearchableAttribute
	private String city;

	@SearchableAttribute
	private String streetLine1;

	@SearchableAttribute
	private String streetLine2;

	@SearchableAttribute
	private String region;

	@SearchableAttribute
	private String postalCode;

	@SearchableAttribute
	private String state;

	@SearchableAttribute
	private String country;

	private String LSC;
	@SearchableAttribute
	public String getLSC()
	{
		return LSC;
	}

	public void setLSC(String lSC)
	{
		LSC = lSC;
	}

	public void _setAddress(Address address)
	{
		this.city = address.getCity();
		this.streetLine1 = address.getStreetLine1();
		this.streetLine2 = address.getStreetLine2();
		this.postalCode = address.getPostalCode();
		this.state = address.getState();
		this.country = address.getCountry();
		this.region = address.getRegion();
	}

	public String getRegion()
	{
		return region;
	}

	public void setRegion(String region)
	{
		this.region = region;
	}

	public String getCity()
	{
		return city;
	}

	public void setCity(String city)
	{
		this.city = city;
	}

	public String getStreetLine1()
	{
		return streetLine1;
	}

	public void setStreetLine1(String streetLine1)
	{
		this.streetLine1 = streetLine1;
	}

	public String getStreetLine2()
	{
		return streetLine2;
	}

	public void setStreetLine2(String streetLine2)
	{
		this.streetLine2 = streetLine2;
	}

	public String getPostalCode()
	{
		return postalCode;
	}

	public void setPostalCode(String postalCode)
	{
		this.postalCode = postalCode;
	}

	public String getState()
	{
		return state;
	}

	public void setState(String state)
	{
		this.state = state;
	}

	public String getCountry()
	{
		return country;
	}

	public void setCountry(String country)
	{
		this.country = country;
	}

	public void setTeamCode(String teamCode)
	{
		this.teamCode = teamCode;
	}


	public String getTeamCode()
	{
		return teamCode;
	}

	public void setFullName(String fullName)
	{
		this.fullName = fullName;
	}

	public String getFullName()
	{
		return fullName;
	}

	public void setShortName(String shortName)
	{
		this.shortName = shortName;
	}

	public String getShortName()
	{
		return shortName;
	}

	public void setHeadCoach(String headCoach)
	{
		this.headCoach = headCoach;
	}

	public String getHeadCoach()
	{
		return headCoach;
	}

	public void setUrl(String url)
	{
		this.url = url;
	}

	public String getUrl()
	{
		return url;
	}
}
