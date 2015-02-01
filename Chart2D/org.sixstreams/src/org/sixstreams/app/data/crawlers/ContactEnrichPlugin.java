package org.sixstreams.app.data.crawlers;


import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import org.sixstreams.app.data.Company;
import org.sixstreams.app.data.Contact;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;

public class ContactEnrichPlugin
{
   PersistenceManager pm = new PersistenceManager();

   private Map<String, Company> cache = new WeakHashMap<String, Company>();
   private long noOfHits = 1;
   
   public void enrich(Contact person)
   {
      String dunsNumber = person.getDunsNumber();
      if (dunsNumber != null && dunsNumber.trim().length() > 0)
      {
         Company company = cache.get(dunsNumber);
         try
         {
            if (company == null)
            {
               List<Company> companies = pm.query("dunsNumber:" + dunsNumber, Company.class, 0, 10);
               if (companies != null && companies.size() > 0)
               {
                  company = (Company) companies.get(0);
                  System.err.println("Found company " + dunsNumber);
               }
               else
               {
                  company = new Company();
                  company.setDunsNumber(dunsNumber);
                  company.setCEO("DummyCompany");
               }
               //cache it
               cache.put(dunsNumber, company);
            }
            else if(!"DummyCompany".equals(company.getCEO()))
            {
               System.err.println("Hit cache " + (noOfHits ++ ) + " " + dunsNumber);
            }
            
            if (company != null && !"DummyCompany".equals(company.getCEO()))
            {
               System.err.println("Enrich " + person.getFirstName() + " " + person.getLastName());
               person.setStreet1(company.getStreet1());
               person.setCity(company.getCity());
               person.setState(company.getState());
               person.setCompanyName(company.getName());
               person.setCountry(company.getCountry());
               
               person.setPostalCode(company.getPostalCode());
               
               person.setEmployees(company.getEmployees());
               person.setRevenue(company.getRevenue());
               person.setIndustry(company.getIndustry());
               
               person.setSubIndustry(company.getSubIndustry());
               person.setDomainType(company.getWebsite());
               person.setFortuneRank(company.getFortuneRank());
               person.setOwnership(company.getOwnership());
               person.setLatitude(company.getLatitude());
               person.setLongitude(company.getLongitude());
            }
         }
         catch (SearchException e)
         {
            e.printStackTrace();
         }
      }
   }
}
