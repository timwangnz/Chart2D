package org.sixstreams.metadata;

import java.util.ArrayList;
import java.util.List;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.data.java.annotations.SearchableAttribute;

@Searchable(title = "name")
public class Application extends MetaDataCommon
{
   private String owner;
   private String firstName;
   private String lastName;
   private String email;
   private String phone;
   private String iconUrl;
   
   private int seq;
   
   private String context;

   private List<String> imageUrls;
   
   private List<String> widgets;

   private List<String> ACLs;
   
   @SearchableAttribute(facetName = "type", facetPath = "type")
   private String type;
   @SearchableAttribute(facetName = "platform", facetPath = "platform")
   private String platform;
   @SearchableAttribute(facetName = "template", facetPath = "template")
   private String template;
   private String version;
   


   public void setOwner(String owner)
   {
      this.owner = owner;
   }

   public String getOwner()
   {
      return owner;
   }

   public void setFirstName(String firstName)
   {
      this.firstName = firstName;
   }

   public String getFirstName()
   {
      return firstName;
   }

   public void setLastName(String lastName)
   {
      this.lastName = lastName;
   }

   public String getLastName()
   {
      return lastName;
   }

   public void setEmail(String email)
   {
      this.email = email;
   }

   public String getEmail()
   {
      return email;
   }

   public void setPhone(String phone)
   {
      this.phone = phone;
   }

   public String getPhone()
   {
      return phone;
   }

   public void setType(String type)
   {
      this.type = type;
   }

   public String getType()
   {
      return type;
   }

   public void setPlatform(String platform)
   {
      this.platform = platform;
   }

   public String getPlatform()
   {
      return platform;
   }

   public void setTemplate(String template)
   {
      this.template = template;
   }

   public String getTemplate()
   {
      return template;
   }

   public void setIconUrl(String iconUrl)
   {
      this.iconUrl = iconUrl;
   }

   public String getIconUrl()
   {
      return iconUrl;
   }

   public void setImageUrls(List<String> imageUrls)
   {
      this.imageUrls = imageUrls;
   }

   public List<String> getImageUrls()
   {
      return imageUrls;
   }

   public void setVersion(String version)
   {
      this.version = version;
   }

   public String getVersion()
   {
      return version;
   }

   public void setACLs(List<String> ACLs)
   {
      this.ACLs = ACLs;
   }

   public List<String> getACLs()
   {
      return ACLs;
   }

   public void setSeq(int seq)
   {
      this.seq = seq;
   }

   public int getSeq()
   {
      return seq;
   }

   public void setContext(String context)
   {
      this.context = context;
   }

   public String getContext()
   {
      return context;
   }

   public void setWidgets(List<String> widgets)
   {
      this.widgets = widgets;
   }

   public List<String> getWidgets()
   {
      if (widgets == null)
      {
         widgets = new ArrayList<String>();
      }
      return widgets;
   }
}
