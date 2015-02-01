package org.sixstreams.app.data.crawlers;

import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import org.sixstreams.app.data.Company;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;


public class CompanyEnrichPlugin
{
   private PersistenceManager pm = new PersistenceManager();

   private Map<String, Company> cache = new WeakHashMap<String, Company>();
   private long noOfHits = 1;
   
   public void enrich(Company company1)
   {
      String dunsNumber = company1.getDunsNumber();
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
               
               company1.setStreet1(company.getStreet1());
               company1.setCity(company.getCity());
               company1.setState(company.getState());
             
               company1.setCountry(company.getCountry());
               //company1.setCounty(company.getCounty());
               company1.setPostalCode(company.getPostalCode());
               company1.setRevenue(company.getRevenue());
               company1.setIndustry(company.getIndustry());
               company1.setSubIndustry(company.getSubIndustry());
               company1.setFortuneRank(company.getFortuneRank());
               company1.setOwnership(company.getOwnership());
            }
         }
         catch (SearchException e)
         {
            e.printStackTrace();
         }
      }
   }
}
