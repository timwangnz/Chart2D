package org.sixstreams.app.data;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.social.SocialLocatable;

@Searchable(title = "name")
public class Company extends SocialLocatable
{

	private String industry;
	private String subIndustry;
	
	private String name;
	private String domainName;
	private String sector;
	private String ownership;
	private String stockSymbol;
	private String CEO;
	private long revenue;
	private String sizeInRevenue;
	private long employees;
	private String sizeInEmployees;
	private long marketCap;

	private boolean publicTraded;
	private int yearIPO;
	private String mailingAddress;
	private int yearStarted;
	private String currencyCode;
	private String parentDuns;
	private String dunsNumber;
	private String description;
	private String fortuneRank;

	public long getMarketCap()
	{
		return marketCap;
	}

	public void setMarketCap(long marketCap)
	{
		this.marketCap = marketCap;
	}

	public String getSector()
	{
		return sector;
	}

	public void setSector(String sector)
	{
		this.sector = sector;
	}

	public boolean isPublicTraded()
	{
		return publicTraded;
	}

	public void setPublicTraded(boolean publicTraded)
	{
		this.publicTraded = publicTraded;
	}

	public int getYearIPO()
	{
		return yearIPO;
	}

	public void setYearIPO(int yearIPO)
	{
		this.yearIPO = yearIPO;
	}

	public void setName(String mName)
	{
		this.name = mName;
	}

	public String getName()
	{
		return name;
	}

	public void setDomainName(String mDomainName)
	{
		this.domainName = mDomainName;
	}

	public String getDomainName()
	{
		return domainName;
	}

	public void setOwnership(String mOwnership)
	{
		this.ownership = mOwnership;
	}

	public String getOwnership()
	{
		return ownership;
	}

	public void setStockSymbol(String mStockSymbol)
	{
		this.stockSymbol = mStockSymbol;
	}

	public String getStockSymbol()
	{
		return stockSymbol;
	}

	public void setCEO(String mCEO)
	{
		this.CEO = mCEO;
	}

	public String getCEO()
	{
		return CEO;
	}

	public void setRevenue(long mRevenue)
	{
		this.revenue = mRevenue;
	}

	public long getRevenue()
	{
		return revenue;
	}

	public void setEmployees(long mEmployeeLevel)
	{
		this.employees = mEmployeeLevel;
	}

	public long getEmployees()
	{
		return employees;
	}

	public String getMailingAddress()
	{
		return mailingAddress;
	}

	public void setMailingAddress(String mailingAddress)
	{
		this.mailingAddress = mailingAddress;
	}

	public int getYearStarted()
	{
		return yearStarted;
	}

	public void setYearStarted(int yearStarted)
	{
		this.yearStarted = yearStarted;
	}

	public String getCurrencyCode()
	{
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode)
	{
		this.currencyCode = currencyCode;
	}

	public String getParentDuns()
	{
		return parentDuns;
	}

	public void setParentDuns(String parentDuns)
	{
		this.parentDuns = parentDuns;
	}

	public String getDunsNumber()
	{
		return dunsNumber;
	}

	public void setDunsNumber(String dunsNumber)
	{
		this.dunsNumber = dunsNumber;
	}

	public String toString()
   {
      StringBuffer content = new StringBuffer();
      content.append("Name:").append(name).append(" - ").append(getId()).append("\n");
      content.append("Address:\n\t").append(this.getStreet1());
      content.append("\n\t").append(getCity()).append(getState()).append(", ").append(getPostalCode());
      content.append("\n\t").append(getCountry());
      content.append("\nLocation:\t").append(this.getMetro());

      if (CEO != null && CEO.length() != 0)
      {
         content.append("\nCEO:\t").append(CEO);
      }
      content.append("\nIndustry:\t").append(getIndustry());

      content.append("\nSub Industry:\t").append(getSubIndustry());
      content.append("\nTags:\t").append(getTags());

      content.append("\nDescription:\t").append(this.getDescription());
      content.append("\nRevenue:\t").append(revenue);
      content.append("\nNumber of Employee:\t").append(employees);
      return content.toString();
   }

	public void setFortuneRank(String fortuneRank)
	{
		this.fortuneRank = fortuneRank;
	}

	public String getFortuneRank()
	{
		return fortuneRank;
	}

	public void setSizeInRevenue(String sizeInRevenue)
	{
		this.sizeInRevenue = sizeInRevenue;
	}

	public String getSizeInRevenue()
	{
		return sizeInRevenue;
	}

	public void setSizeInEmployees(String sizeInEmployees)
	{
		this.sizeInEmployees = sizeInEmployees;
	}

	public String getSizeInEmployees()
	{
		return sizeInEmployees;
	}

	public String getIndustry()
	{
		return industry;
	}

	public void setIndustry(String industry)
	{
		this.industry = industry;
	}

	public String getSubIndustry()
	{
		return subIndustry;
	}

	public void setSubIndustry(String subIndustry)
	{
		this.subIndustry = subIndustry;
	}

	public String getDescription()
	{
		return description;
	}

	public void setDescription(String description)
	{
		this.description = description;
	}
}
