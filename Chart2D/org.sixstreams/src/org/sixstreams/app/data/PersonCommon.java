package org.sixstreams.app.data;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.sixstreams.search.data.java.annotations.SearchableAttribute;


public class PersonCommon
   extends CustomerCommon
{
   @SearchableAttribute(sequence = 0, groupName = "name")
   private String salutation;
   @SearchableAttribute(sequence = 1, groupName = "profile")
   private String gender;
   @SearchableAttribute(sequence = 2, groupName = "profile")
   private Date dateOfBirth;

   @SearchableAttribute(sequence = 1, groupName = "name")
   private String firstName;
   @SearchableAttribute(sequence = 2, groupName = "name")
   private String lastName;
   @SearchableAttribute(sequence = 3, groupName = "name")
   private String middleName;
   @SearchableAttribute(sequence = 4, groupName = "name")
   private String screenName;
   @SearchableAttribute(sequence = 5, groupName = "name", readableType="imageUrl")
   private String imgUrl;
   @SearchableAttribute(sequence = 6, groupName = "name")
   private String suffix;

   @SearchableAttribute(sequence = 1, groupName = "contact")
   private String workPhone;
   @SearchableAttribute(sequence = 2, groupName = "contact")
   private String cellPhone;
   @SearchableAttribute(sequence = 3, groupName = "contact")
   private String workEmail;

   @SearchableAttribute(sequence = 4, groupName = "job")
   private String jobDesc;
   @SearchableAttribute(groupName = "job", sequence = 2, facetName = "job", facetPath = "jobTitle")
   private String jobTitle;
   @SearchableAttribute(sequence = 3, groupName = "job", facetName="Level", facetPath="jobLevel")
   private String jobLevel;
   @SearchableAttribute(sequence = 0, groupName = "organization", facetName = "company",
                        facetPath = "companyName")
   private String companyName;
   
   @SearchableAttribute(sequence = 1, groupName = "organization", facetName="department", facetPath="department")
   private String department;
   
   @SearchableAttribute(sequence = 1, groupName = "social")
   private List<String> connections;


   public String getSuffix()
   {
      return suffix;
   }

   public void setSuffix(String suffix)
   {
      this.suffix = suffix;
   }

   public void setFirstName(String firstName)
   {
      this.firstName = firstName;
   }

   public String getFirstName()
   {
      return firstName;
   }

   public String getContent()
   {
      return toString();
   }

   public void setLastName(String lastName)
   {
      this.lastName = lastName;
   }

   public String getLastName()
   {
      return lastName;
   }

   public void setMiddleName(String middleName)
   {
      this.middleName = middleName;
   }

   public String getMiddleName()
   {
      return middleName;
   }

   public void setImgUrl(String imgUrl)
   {
      this.imgUrl = imgUrl;
   }

   public String getImgUrl()
   {
      return imgUrl;
   }

   public void setWorkPhone(String workPhone)
   {
      this.workPhone = workPhone;
   }

   public String getWorkPhone()
   {
      return workPhone;
   }

   public void setCellPhone(String cellPhone)
   {
      this.cellPhone = cellPhone;
   }


   public String getCellPhone()
   {
      return cellPhone;
   }

   public void setWorkEmail(String workEmail)
   {
      this.workEmail = workEmail;
   }


   public String getWorkEmail()
   {
      return workEmail;
   }

   public void setJobDesc(String jobDesc)
   {
      this.jobDesc = jobDesc;
   }


   public String getJobDesc()
   {
      return jobDesc;
   }

   public void setJobTitle(String jobTitle)
   {
      this.jobTitle = jobTitle;
   }


   public String getJobTitle()
   {
      return jobTitle;
   }

   public void setJobLevel(String jobLevel)
   {
      this.jobLevel = jobLevel;
   }


   public String getJobLevel()
   {
      return jobLevel;
   }

   public void setCompanyName(String companyName)
   {
      this.companyName = companyName;
   }


   public String getCompanyName()
   {
      return companyName;
   }

   public void setDepartment(String department)
   {
      this.department = department;
   }


   public String getDepartment()
   {
      return department;
   }

   public void setScreenName(String screenName)
   {
      this.screenName = screenName;
   }


   public String getScreenName()
   {
      return screenName;
   }

   public void setSalutation(String salutation)
   {
      this.salutation = salutation;
   }

   public String getSalutation()
   {
      return salutation;
   }

   public void setGender(String gender)
   {
      this.gender = gender;
   }

   public String getGender()
   {
      return gender;
   }

   public void setDateOfBirth(Date dateOfBirth)
   {
      this.dateOfBirth = dateOfBirth;
   }


   public Date getDateOfBirth()
   {
      return dateOfBirth;
   }

   public String toString()
   {
      String total = "Name: " + firstName + " " + lastName + " - " + getId() + "\n" +
         "Address: \n\t" + getStreetAddress() + "\n" +
         "\t" + getCity() + " " + getState() + ", " + getZipCode() + "\n" +
         "\t" + getCountry() + "\n" +
         "Email: " + getWorkEmail

         () + "\n" +
         "Phone: " + getWorkPhone() + "\n" +
         "Cell: " + getCellPhone() + "\n" +
         "Title: " + getJobTitle() + "\n" +
         "Job : " + this.getJobDesc() + " " + getJobLevel() + "\n" +
         "Organization: " + getDepartment() + "\n" +
         "Location: " + getMetroArea() + "\n";

      if (this.imgUrl != null && imgUrl.length() != 0)
      {
         total += "\nProfile Image URL: " + imgUrl + "\n";
      }
      return total;
   }

   public void setConnections(List<String> connections)
   {
      this.connections = connections;
   }

   public List<String> getConnections()
   {
      if (connections == null)
      {
         connections = new ArrayList<String>();
      }
      return connections;
   }
}
