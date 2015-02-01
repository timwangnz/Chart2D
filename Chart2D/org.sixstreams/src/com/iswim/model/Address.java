package com.iswim.model;

public class Address extends Inheritable
{
	public static final String HOME="HOME", BILLING="BILLING", SHIPPING = "SHIPPING";
	public static final String EVENT="EVENT", COMPANY="COMPANY", PERSON = "PERSON";

	private String city;
	

	private String streetLine1;
	

	private String streetLine2;
	
	private String region;
	
	private String postalCode;
	
	private String state;
	
	private String country;

	private String ownerId;
	
	private String type = HOME;
	

	private String ownerType = PERSON;
	
	public String getOwnerType()
	{
		return ownerType;
	}

	public void setOwnerType(String ownerType)
	{
		this.ownerType = ownerType;
	}

	public String getType()
	{
		return type;
	}

	public void setType(String type)
	{
		this.type = type;
	}

	public Address(String name, String street1, String street2, String city2, String state2, String country2, String postalCode2)
	{
		super();
		ownerId = name;
		streetLine1 = street1;
		streetLine2 = street2;
		city = city2;
		state = state2;
		postalCode = postalCode2;
		country = country2;
	}

	public Address(String addressLine)
	{
		streetLine1 = addressLine;
	}

	public String getOwnerId()
	{
		return ownerId;
	}

	public void setOwnerId(String ownerId)
	{
		this.ownerId = ownerId;
	}

	public void setAddress(Address address)
	{
		this.city = address.city;
		this.streetLine1 = address.streetLine1;
		this.streetLine2 = address.streetLine2;
		this.postalCode = address.postalCode;
		this.state = address.state;
		this.country = address.country;
		this.region = address.region;
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
}
