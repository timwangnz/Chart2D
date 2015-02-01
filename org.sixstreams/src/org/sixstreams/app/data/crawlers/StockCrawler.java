package org.sixstreams.app.data.crawlers;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.app.data.crawlers.yahoo.YahooFinance;
import org.sixstreams.app.marketIntel.Stock;
import org.sixstreams.search.SearchHits;
import org.sixstreams.search.data.PersistenceManager;

public class StockCrawler extends TextCrawler
{
	Logger sLogger = Logger.getLogger(StockCrawler.class.getName());
	static File nasdaq = new File("/Users/anpwang/cronjobs/companylist/nasdaq.csv");
	static File amex = new File("/Users/anpwang/cronjobs/companylist/amex.csv");
	static File nyse = new File("/Users/anpwang/cronjobs/companylist/nyse.csv");
	
	List<YahooFinance> enrichers = new ArrayList<YahooFinance>();
	
	static long totalStocks = 10;
	static int threads = 5;
	static int time2WaitForThread = 1000;
	static
	{
		Logger.getLogger("org").setLevel(Level.SEVERE);
	}

	public static boolean isInitialized()
	{
		PersistenceManager pm = new PersistenceManager();
		try
		{
			SearchHits hits = pm.search("*", Stock.class);
			return hits.getCount() > 0;
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			pm.close();
		}
		return false;
	}
	
	public static void main(String[] args)
	{
		StockCrawler crawler = new StockCrawler();
		
		long startedAt = System.currentTimeMillis();
		for (int i = 0; i < threads; i++)
		{
			crawler.enrichers.add(new YahooFinance());
		}
		
		crawler.withQuotes = true;
		crawler.crawl(nasdaq);
		crawler.crawl(nyse);
		crawler.crawl(amex);
		
		System.err.println("Time spent for " + crawler.getTotalCrawled() + " items is " + (System.currentTimeMillis() - startedAt) + " ms");
	
		//StockCrawler.main(args);
	}

	public StockCrawler()
	{
		this.cDelimitor = ',';
		this.delimitor = "\",";
		this.dateFormat = "MM-dd-yyyy";
		this.maxRecordsToCrawl = totalStocks;
	}

	@Override
	protected Object toObject(Map<String, String> map)
	{
		Stock stock = new Stock();
		try
		{
			stock.setId(map.get("Symbol").trim());
			stock.setOwnership("public");
			stock.setIndustry(map.get("industry"));
			stock.setName(map.get("Name"));
			stock.setSector(map.get("Sector"));
			stock.setStockSymbol(map.get("Symbol"));
			stock.setSourceUrl(map.get("Summary Quote"));

			if (stock.getStockSymbol().contains("^") || stock.getStockSymbol().contains("/")|| stock.getStockSymbol().contains("~"))
			{
				sLogger.fine("skip for its name has special char - " + stock.getStockSymbol());
				return null;
			}
			
			if (stock.getIndustry().equals("n/a") || stock.getSector().equals("n/a"))
			{
				sLogger.fine("skip as it does not have sector or industry - " + stock.getStockSymbol());
				return null;
			}
			
			try
			{
				stock.setPrice(Float.valueOf(map.get("LastSale")));
				stock.setMarketCap(Long.valueOf(map.get("MarketCap")));
			}
			catch (Exception e)
			{
				stock.setMarketCap(-1L);
			}
			
			try
			{
				stock.setYearIPO(Integer.valueOf(map.get("IPOYear")));
			}
			catch (Exception e)
			{
				stock.setYearIPO(-1);
			}
			
			this.enrichStock(stock);
			sLogger.info("Process " + stock.getStockSymbol() + " " + stock.getPrice());
			return stock;
		}
		catch (Exception e)
		{
			sLogger.log(Level.SEVERE, "Failed to parse stock", e);
		}
		return null;
	}

	void enrichStock(Stock stock) throws Exception
	{
		YahooFinance yf = getIdleEnricher();
		while (true)
		{
			if (yf != null)
			{
				yf.setCompany(stock);
				sLogger.fine("Enrich " + stock.getStockSymbol());
				new Thread(yf).start();
				break;
			}
			Thread.sleep(time2WaitForThread);
			yf = getIdleEnricher();
		}
	}
	
	YahooFinance getIdleEnricher()
	{
		for (YahooFinance yf : enrichers)
		{
			if (!yf.isBusy())
			{
				yf.setBusy(true);
				return yf;
			}
		}
		return null;
	}

}
