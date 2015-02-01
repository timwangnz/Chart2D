package org.sixstreams.social;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;


public class SocialLocatable extends Socialable
{

	private String email;
	private String phone;
	private String street1;
	private String street2;
	
	@SearchableAttribute(facetName="city", facetPath="city")
	private String city;
	private String postalCode;
	
	@SearchableAttribute(facetName="state", facetPath="state", lov="org.sixstreams.social.LocationStateLov")
	private String state;
	
	@SearchableAttribute(lov="org.sixstreams.social.LocationCountryLov")
	private String country;
	
	@SearchableAttribute(facetName="metro", facetPath="metro", lov="org.sixstreams.social.LocationMetroLov")
	private String metro;
	
	private Float latitude = 0.0f;
	private Float longitude = 0.0f;
	
	public String getEmail()
	{
		return email;
	}

	public void setEmail(String email)
	{
		this.email = email;
	}

	public String getPhone()
	{
		return phone;
	}

	public void setPhone(String phone)
	{
		this.phone = phone;
	}

	public String getStreet1()
	{
		return street1;
	}

	public void setStreet1(String street1)
	{
		this.street1 = street1;
	}

	public String getCity()
	{
		return city;
	}

	public void setCity(String city)
	{
		this.city = city;
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

	public String getStreet2()
	{
		return street2;
	}

	public void setStreet2(String street2)
	{
		this.street2 = street2;
	}

	public Float getLatitude()
	{
		return latitude;
	}

	public void setLatitude(Float latitude)
	{
		this.latitude = latitude;
	}

	public Float getLongitude()
	{
		return longitude;
	}

	public void setLongitude(Float longitude)
	{
		this.longitude = longitude;
	}

	public String getMetro()
	{
		return metro;
	}

	public void setMetro(String metro)
	{
		this.metro = metro;
	}

}
