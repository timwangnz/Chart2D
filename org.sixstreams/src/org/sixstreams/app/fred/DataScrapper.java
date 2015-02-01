package org.sixstreams.app.fred;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;

import java.net.URL;
import java.net.URLConnection;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.commons.io.IOUtils;

import org.sixstreams.search.IndexingException;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.util.XMLTable;
import org.sixstreams.search.util.XMLUtil;


public class DataScrapper
{

  //ef673da26430e206a8b7d3ce658b7162
  static String fredCategory =
    "http://api.stlouisfed.org/fred/category/children?api_key=ef673da26430e206a8b7d3ce658b7162&category_id=";

  static String fredSeries =
    "http://api.stlouisfed.org/fred/category/series?api_key=ef673da26430e206a8b7d3ce658b7162&category_id=";
  
  static String fredObservation = "http://api.stlouisfed.org/fred/series/observations?api_key=ef673da26430e206a8b7d3ce658b7162&series_id=";
  static
  {
    Logger.getLogger("").setLevel(Level.SEVERE);
  }

  public static void main(String[] args)
  {
    DataScrapper scapper = new DataScrapper();
    
    //scapper.getSeries("33122");
    scapper.crawlFred("0");
  }

  Map<String, FredCategory> categoriesCrawled = new HashMap<String, FredCategory>();
  Map<String, TimeSeries> seriesCrawled = new HashMap<String, TimeSeries>();

  public void getSeries(String categoryId)
  {
    String xml = read(fredSeries + categoryId);
    XMLTable hashMap = XMLUtil.toHashMap(xml);

    Object obj = hashMap.get("seriess.series");

    if (obj instanceof XMLTable)
    {
      List list = new ArrayList();
      list.add(obj);
      obj = list;
    }
    
    if (obj != null && obj instanceof List)
    {
      List<XMLTable> categories = (List<XMLTable>) obj;
      List<TimeSeries> fredTimeSerieses = new ArrayList<TimeSeries>();
      for (XMLTable tbl: categories)
      {
        String seriesId = "" + tbl.get("id");
        if (seriesCrawled.get(seriesId) == null)
        {
          TimeSeries fredSeries = new TimeSeries(tbl);
          FredCategory parentFredCat = categoriesCrawled.get(categoryId);

          if (parentFredCat != null)
          {
            fredSeries.setCategoryId(parentFredCat.getId());
            fredSeries.setDesc(parentFredCat.getDesc() + " " + fredSeries.getTitle());
          }
          else
          {
            fredSeries.setDesc(fredSeries.getTitle());
          }
          seriesCrawled.put(seriesId, fredSeries);
          fredTimeSerieses.add(fredSeries);
        }
      }
      
      if (fredTimeSerieses.size() > 0)
      {
        try
        {
          pm.insert(fredTimeSerieses);
        }
        catch (IndexingException e)
        {
          e.printStackTrace();
        }
      }
    }
    else if (obj != null)
    {
      System.err.println(obj);
    }
  }
  PersistenceManager pm = new PersistenceManager();
  public void crawlFred(String id)
  {

    String xml = read(fredCategory + id);
    XMLTable hashMap = XMLUtil.toHashMap(xml);

    Object obj = hashMap.get("categories.category");

    if (obj instanceof XMLTable)
    {
      List list = new ArrayList();
      list.add(obj);
      obj = list;
    }
    
    if (obj != null && obj instanceof List)
    {
      List<XMLTable> categories = (List<XMLTable>) obj;
      List<FredCategory> fredCategories = new ArrayList<FredCategory>();
      for (XMLTable tbl: categories)
      {
        String categoryId = "" + tbl.get("id");
        System.err.println(categoryId + " " + tbl.get("name") + " " + tbl.get("parent_id"));
        if (categoriesCrawled.get(categoryId) == null)
        {
          FredCategory fredCat = new FredCategory(tbl);
          FredCategory parentFredCat = categoriesCrawled.get(fredCat.getParentId());
          if (parentFredCat != null)
          {
            fredCat.setDesc(parentFredCat.getDesc() + " " + fredCat.getName());
          }
          else
          {
            fredCat.setDesc(fredCat.getName());
          }
          categoriesCrawled.put(categoryId, fredCat);

          fredCategories.add(new FredCategory(tbl));
          getSeries(categoryId);
          crawlFred(categoryId);
        }
      }
      try
      {
        pm.insert(fredCategories);
      }
      catch (IndexingException e)
      {
        e.printStackTrace();
      }
    }
    else if (obj != null)
    {
      System.err.println(obj);
    }
  }

  public String read(String urlString)
  {
    try
    {
      URL url = new URL(urlString);
      URLConnection urlConnection = url.openConnection();

      StringWriter writer = new StringWriter();
      IOUtils.copy(urlConnection.getInputStream(), writer, "UTF-8");
      return writer.toString();
    }
    catch (Throwable e)
    {
      //
    }
    return null;
  }

  public static void scrap()
  {
    DataScrapper ds = new DataScrapper();
    Map<String, TimeSeries> serieses = ds.loadSeries("/Users/anpwang/FRED2_csv_2/README_TITLE_SORT.txt");
    long timeAt = System.currentTimeMillis();

    for (String series: serieses.keySet())
    {
      TimeSeries ts = serieses.get(series);
      processTS(ts);

      System.err.println(ts.getUrl());
    }
    System.err.println("total points " + totalCount + " " + (System.currentTimeMillis() - timeAt));
  }

  public static void processTS(TimeSeries timeSeries)
  {
    BufferedReader br = null;
    String sCurrentLine;
    try
    {
      String filename = "/Users/anpwang/FRED2_csv_2/data/" + timeSeries.getUrl();
      InputStream inputStream = new FileInputStream(new File(filename));

      // TimeSeries.class.getResourceAsStream(name);
      br = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));

      //Map<Date, TimeValue> seriese = new HashMap<Date, TimeValue>();

      PersistenceManager pm = new PersistenceManager();
      List<TimeValue> batch = new ArrayList<TimeValue>();
      while ((sCurrentLine = br.readLine()) != null)
      {
        String[] element = sCurrentLine.split(",");
        if (element.length == 2 && !element[0].trim().startsWith("DATE"))
        {
          TimeValue ts = new TimeValue(sCurrentLine);
          //seriese.put(ts.getTime(), ts);
          batch.add(ts);
          totalCount++;
        }
      }

      try
      {
        pm.insert(batch);
        batch.clear();
      }
      catch (IndexingException e)
      {
        e.printStackTrace();
      }
      pm.close();
      inputStream.close();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  static long totalCount = 0;

  public static Map<String, TimeSeries> loadSeries(String name)
  {
    BufferedReader br = null;
    String sCurrentLine;
    try
    {
      InputStream inputStream = new FileInputStream(new File(name));

      // TimeSeries.class.getResourceAsStream(name);
      br = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));

      Map<String, TimeSeries> seriese = new HashMap<String, TimeSeries>();

      while ((sCurrentLine = br.readLine()) != null)
      {
        String[] element = sCurrentLine.split(";");

        if (element.length == 6 && !element[0].trim().startsWith("File"))
        {
          TimeSeries ts = new TimeSeries(sCurrentLine);
          seriese.put(ts.getId(), ts);

        }
      }
      inputStream.close();
      return seriese;
    }
    catch (Exception e)
    {
      return new HashMap<String, TimeSeries>();
    }
  }
}
