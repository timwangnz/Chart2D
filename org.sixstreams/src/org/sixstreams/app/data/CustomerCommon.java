package org.sixstreams.app.data;

import org.sixstreams.search.data.DataCommon;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;


public class CustomerCommon
   extends DataCommon
{
   @SearchableAttribute(isDisplayable = false)
   private String contactId;
   @SearchableAttribute(sequence = 0, groupName = "contact")
   private String phone;
   @SearchableAttribute(sequence = 1, groupName = "contact")
   private String email;
   @SearchableAttribute(sequence = 10, groupName = "profile", facetName="industry", facetPath="industry")
   private String industry;
   @SearchableAttribute(sequence = 11, groupName = "profile")
   private String subIndustry;
   @SearchableAttribute(sequence = 0, groupName = "address")
   private String streetAddress;
   @SearchableAttribute(sequence = 1, groupName = "address")
   private String streetAddress2;
   @SearchableAttribute(sequence = 2, groupName = "address")
   private String state;
   @SearchableAttribute(sequence = 3, groupName = "address")
   private String country;
   @SearchableAttribute(sequence = 4, groupName = "address")
   private String zipCode;
   @SearchableAttribute(sequence = 5, groupName = "address", facetName="city", facetPath="city")
   private String city;
   @SearchableAttribute(sequence = 6, groupName = "address")
   private String metroArea;

   @SearchableAttribute(sequence = 7, groupName = "address")
   private String county;
   @SearchableAttribute(sequence = 8, groupName = "address")
   private Float latitude;
   @SearchableAttribute(sequence = 9, groupName = "address")
   private Float longitude;

   public String getCounty()
   {
      return county;
   }

   public void setCounty(String county)
   {
      this.county = county;
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

   public String getStreetAddress()
   {
      return streetAddress;
   }

   public void setStreetAddress(String streetAddress)
   {
      this.streetAddress = streetAddress;
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

   public String getZipCode()
   {
      return zipCode;
   }

   public void setZipCode(String zipCode)
   {
      this.zipCode = zipCode;
   }

   public String getStreetAddress2()
   {
      return streetAddress2;
   }

   public void setStreetAddress2(String streetAddress2)
   {
      this.streetAddress2 = streetAddress2;
   }

   public String getCity()
   {
      return city;
   }

   public void setCity(String city)
   {
      this.city = city;
   }

   public String getMetroArea()
   {
      return metroArea;
   }

   public void setMetroArea(String metroArea)
   {
      this.metroArea = metroArea;
   }

   public void setIndustry(String industry)
   {
      this.industry = industry;
   }

   @SearchableAttribute(facetName = "industry", facetPath = "industry", groupName = "Industry", sequence = 25)
   public String getIndustry()
   {
      return industry;
   }

   public void setSubIndustry(String subIndustry)
   {
      this.subIndustry = subIndustry;
   }

   @SearchableAttribute(facetName = "industry", facetPath = "industry.subIndustry", groupName = "Industry",
                        sequence = 26)
   public String getSubIndustry()
   {
      return subIndustry;
   }

   public void setContactId(String contactId)
   {
      this.contactId = contactId;
   }

   @SearchableAttribute
   public String getContactId()
   {
      return contactId;
   }

   public void setPhone(String phone)
   {
      this.phone = phone;
   }

   @SearchableAttribute(groupName = "contact", sequence = 32)
   public String getPhone()
   {
      return phone;
   }

   public void setEmail(String email)
   {
      this.email = email;
   }

   @SearchableAttribute(groupName = "contact", sequence = 34)
   public String getEmail()
   {
      return email;
   }
}
