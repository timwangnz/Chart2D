package org.sixstreams.app.fred;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Date;

import org.sixstreams.search.data.java.annotations.Searchable;
import org.sixstreams.search.util.XMLTable;
import org.sixstreams.social.Socialable;


@Searchable(title = "type", isSecure = false)
public class TimeSeries
  extends Socialable
{


  static SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
  static SimpleDateFormat timeFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

  private String type;

  private String title;

  private String units;

  private String frequency;

  private float popularity;

  private String seasonalAdjustment;

  private String url;

  private Date start;

  private Date end;

  Date lastUpdated;

  private String categoryId;

  private String desc;
  
  public TimeSeries(XMLTable xml)

  {
    try
    {
      setId("" + xml.get("BOPBCAN"));
      title = "" + xml.get("title");
      frequency = "" + xml.get("frequency");
      units = "" + xml.get("units");
      popularity = Float.valueOf("" + xml.get("popularity")).floatValue();
      seasonalAdjustment = "" + xml.get("seasonal_adjustment");
      start = format.parse("" + xml.get("observation_start"));
      end = format.parse("" + xml.get("observation_end"));
      lastUpdated = timeFormat.parse("" + xml.get("last_updated"));
    }
    catch (ParseException e)
    {
      //eats it
    }
  }

  public TimeSeries(String line)
  {
    String[] element = line.split(";");
    url = element[0].trim().replace("\\", "/");
    title = element[1];
    frequency = element[3];
    units = element[2];
    seasonalAdjustment = element[4];
    try
    {
      lastUpdated = format.parse(element[5]);
    }
    catch (ParseException e)
    {
      lastUpdated = new Date();
    }
  }

  public String getType()
  {
    return type;
  }

  public void setType(String type)
  {
    this.type = type;
  }

  public String getTitle()
  {
    return title;
  }

  public void setTitle(String title)
  {
    this.title = title;
  }

  public String getUnits()
  {
    return units;
  }

  public void setUnits(String units)
  {
    this.units = units;
  }


  public String getUrl()
  {
    return url;
  }

  public void setUrl(String url)
  {
    this.url = url;
  }

  public String getSeasonalAdjustment()
  {
    return seasonalAdjustment;
  }

  public void setSeasonalAdjustment(String seasonalAdjustment)
  {
    this.seasonalAdjustment = seasonalAdjustment;
  }

  public Date getLastUpdated()
  {
    return lastUpdated;
  }

  public void setLastUpdated(Date lastUpdated)
  {
    this.lastUpdated = lastUpdated;
  }

  public void setFrequency(String frequency)
  {
    this.frequency = frequency;
  }

  public String getFrequency()
  {
    return frequency;
  }

  public void setPopularity(float popularity)
  {
    this.popularity = popularity;
  }

  public float getPopularity()
  {
    return popularity;
  }

  public void setStart(Date start)
  {
    this.start = start;
  }

  public Date getStart()
  {
    return start;
  }

  public void setEnd(Date end)
  {
    this.end = end;
  }

  public Date getEnd()
  {
    return end;
  }

  public void setCategoryId(String categoryId)
  {
    this.categoryId = categoryId;
  }

  public String getCategoryId()
  {
    return categoryId;
  }

  public void setDesc(String desc)
  {
    this.desc = desc;
  }

  public String getDesc()
  {
    return desc;
  }
}
