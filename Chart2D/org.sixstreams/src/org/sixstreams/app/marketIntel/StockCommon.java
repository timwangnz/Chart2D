package org.sixstreams.app.marketIntel;


import java.util.Date;

public class StockCommon 
{
   private String stockSymbol;
   private Date date;
   private int year;
   private int month;
   private int day;

   public void setDate(Date date)
   {
      this.date = date;
   }

   public Date getDate()
   {
      return date;
   }

   public void setStockSymbol(String stockSymbol)
   {
      this.stockSymbol = stockSymbol;
   }

   public String getStockSymbol()
   {
      return stockSymbol;
   }

   public void setYear(int year)
   {
      this.year = year;
   }

   public int getYear()
   {
      return year;
   }

   public void setMonth(int month)
   {
      this.month = month;
   }

   public int getMonth()
   {
      return month;
   }

   public void setDay(int day)
   {
      this.day = day;
   }

   public int getDay()
   {
      return day;
   }
   
   public  String toString()
   {
      return BeanPrinter. toString(this) ;
   }
}
