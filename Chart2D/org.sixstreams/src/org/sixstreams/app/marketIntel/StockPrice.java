package org.sixstreams.app.marketIntel;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class StockPrice extends StockCommon
{
   private float open;
   private float close;
   private float high;
   private float low;  
   private float ajustedClose;
   private float volume;
   //private String sourceLine;
   public static DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
   
   public StockPrice(String symbol, String line)
   {
      try
      {
         setStockSymbol(symbol);
         String[] comps = line.split(",");
         setDate(dateFormat.parse(comps[0]));
         open = Float.valueOf(comps[1]);
         high = Float.valueOf(comps[2]);
         low = Float.valueOf(comps[3]);
         close = Float.valueOf(comps[4]);
         volume = Float.valueOf(comps[5]);
         ajustedClose = Float.valueOf(comps[6]);
         //this.sourceLine = line;
      }
      catch (Exception nfe)
      {
         throw new RuntimeException("Failed to handle " + line);
       
      }
   }

   public void setOpen(float open)
   {
      this.open = open;
   }

   public float getOpen()
   {
      return open;
   }

   public void setClose(float close)
   {
      this.close = close;
   }

   public float getClose()
   {
      return close;
   }

   public void setHigh(float high)
   {
      this.high = high;
   }

   public float getHigh()
   {
      return high;
   }

   public void setLow(float low)
   {
      this.low = low;
   }

   public float getLow()
   {
      return low;
   }

   public void setVolume(float volume)
   {
      this.volume = volume;
   }

   public float getVolume()
   {
      return volume;
   }

   public void setAjustedClose(float ajustedClose)
   {
      this.ajustedClose = ajustedClose;
   }

   public float getAjustedClose()
   {
      return ajustedClose;
   }

}
