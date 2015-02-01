package org.sixstreams.app.data.crawlers.yahoo;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.commons.io.IOUtils;
import org.codehaus.jackson.map.ObjectMapper;
import org.htmlparser.Node;
import org.htmlparser.Tag;
import org.htmlparser.filters.HasAttributeFilter;
import org.htmlparser.filters.TagNameFilter;
import org.htmlparser.nodes.TextNode;
import org.htmlparser.tags.Div;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.tags.TableColumn;
import org.htmlparser.tags.TableHeader;
import org.htmlparser.tags.TableRow;
import org.htmlparser.tags.TitleTag;
import org.htmlparser.util.NodeList;
import org.htmlparser.util.SimpleNodeIterator;
import org.sixstreams.app.data.Company;
import org.sixstreams.app.marketIntel.BalanceSheet;
import org.sixstreams.app.marketIntel.Cashflow;
import org.sixstreams.app.marketIntel.IncomeStatement;
import org.sixstreams.app.marketIntel.Stock;
import org.sixstreams.app.marketIntel.StockPrice;
import org.sixstreams.search.Crawler;
import org.sixstreams.search.IndexableDocument;
import org.sixstreams.search.crawl.crawler.ContentMapper;
import org.sixstreams.search.crawl.crawler.CrawlableEndpoint;
import org.sixstreams.search.crawl.crawler.GraphAnalyzer;
import org.sixstreams.search.crawl.web.WebCrawler;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.meta.MetaDataManager;
import org.sixstreams.search.util.CrawlerFactory;
import org.sixstreams.search.util.FileUtil;
import org.sixstreams.search.util.GUIDUtil;

public class YahooFinance implements ContentMapper, GraphAnalyzer, Runnable
{
	Logger sLogger = Logger.getLogger(YahooFinance.class.getName());
	private WebCrawler crawler;
	private MapValueUtil mapValueUtil = new MapValueUtil();

	public static String CACHE_LOCATION = MetaDataManager.getProperty("org.sixstreams.search.web.crawler.cache.location") + "/yahooFinance";

	private int count = 0;
	private List<String> attributes = new ArrayList<String>();
	public final static String CONTENT_TYPE = "finance.yahoo.com/Company";
	private boolean busy;

	public boolean isBusy()
	{
		return busy;
	}

	public void setBusy(boolean busy)
	{
		this.busy = busy;
	}

	static
	{
		CrawlerFactory.registerCrawler(CONTENT_TYPE, WebCrawler.class.getName());
		CrawlerFactory.registerMapper("http://finance.yahoo.com", YahooFinance.class.getName());
	}

	public static String getDateString(Date date)
	{
		SimpleDateFormat format = new SimpleDateFormat();
		format.applyPattern("ddMMyyyy");
		return format.format(date);
	}

	public void save(String stockSymbol, Map<String, Object> stock) throws Exception
	{
		ObjectMapper mapper = new ObjectMapper();
		for (String key : stock.keySet())
		{
			Object object = stock.get(key);
			
			//FileUtil.saveFile(mapper.writeValueAsString(object), CACHE_LOCATION + File.separator + stockSymbol + File.separator + key.replace(".", File.separator), getDateString(new Date()), true);
			FileUtil.saveFile(mapper.writeValueAsString(object), CACHE_LOCATION + File.separator + stockSymbol, key, true);
		}
	}
	
	public Map<String, Object> enrich(Stock company)
	{
		Map<String, Object> jsonableCompany = new HashMap<String, Object>();

		enrichWithProfile(company);
		enrichWithSummary(company);
		enrichWithStats(company);

		jsonableCompany.put(Stock.class.getName(), company);
		jsonableCompany.put(IncomeStatement.class.getName(), getIncomeStatements(company));
		jsonableCompany.put(BalanceSheet.class.getName(), getBalanceSheet(company));
		jsonableCompany.put(Cashflow.class.getName(), getCashflow(company));

		try
		{
			if ("fund".equals(company.getStockType()) || company.getCity() == null)
			{
				System.err.println("Skip " + company.getStockSymbol());
			}
			else
			{
				save(company.getStockSymbol(), jsonableCompany);
			}
		}
		catch (Exception e)
		{
			sLogger.log(Level.SEVERE, "Failed to save company " + company.getStockSymbol(), e);
		}
		
		return jsonableCompany;

	}

	public Object enrichWithProfile(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, String> map = getProfile(stockSymbol);
		mapValueUtil.updateProfile(company, map);
		return company;
	}

	public Object enrichWithStats(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, String> map = getKeyStats(stockSymbol);
		mapValueUtil.updateStats(company, map);
		return company;
	}

	public Object getIncomeStatements(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, Map<String, List<String>>> map = getFinancials(stockSymbol);
		Map<String, List<String>> income = map.get("income");
		return mapValueUtil.createIncomeStatements(company, income);
	}

	public Object getBalanceSheet(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, Map<String, List<String>>> map = getFinancials(stockSymbol);
		Map<String, List<String>> balance = map.get("balanceSheet");
		return mapValueUtil.createBalanceSheets(company, balance);
	}

	public Object getCashflow(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, Map<String, List<String>>> map = getFinancials(stockSymbol);
		Map<String, List<String>> cashflow = map.get("cashflow");

		return mapValueUtil.createCashflows(company, cashflow);

	}

	public Object getPrices(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		try
		{
			List<StockPrice> prices = getHistoricalPrices(stockSymbol);
			Date latestDate = null;
			for (StockPrice price : prices)
			{
				latestDate = latestDate == null || latestDate.before(price.getDate()) ? price.getDate() : latestDate;
			}
			// persistenceManager.insert(prices);
			// MetaDataObject.putValue("getHistoricalPrices", stockSymbol,
			// latestDate);
			return prices;

		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return Collections.EMPTY_LIST;
	}

	public Object enrichWithSummary(Stock company)
	{
		String stockSymbol = company.getStockSymbol();
		Map<String, String> map = this.getSummary(stockSymbol);
		mapValueUtil.updateSummary(company, map);
		return company;
	}

	private List<StockPrice> getHistoricalPrices(String symbol)
	{
		List<StockPrice> prices = new ArrayList<StockPrice>();
		if (symbol == null)
		{
			return prices;
		}

		if (crawler == null)
		{
			crawler = new WebCrawler();
		}

		String url = "http://finance.yahoo.com/q/hp?s=" + symbol.trim() + "+Historical+Prices";
		NodeList nodeList = crawler.retreive(url);

		// List<StockPrice> latestPrices = toPrices(symbol, nodeList);

		// if current page does not have all the pricess, pull from csv
		prices.clear();

		List<String> urls = toUrls(nodeList);
		if (urls.size() > 0 && urls.get(0) != null)
		{
			InputStream inputStream = crawler.read(urls.get(0));
			StringWriter writer = new StringWriter();
			try
			{
				IOUtils.copy(inputStream, writer, "UTF-8");
				String theString = writer.toString();
				BufferedReader in = new BufferedReader(new StringReader(theString));
				String line = in.readLine();
				while (line != null)
				{
					try
					{
						prices.add(new StockPrice(symbol, line));
					}
					catch (Exception e)
					{
						System.err.println("Failed to handle line " + line + "\n" + e.toString());
					}
					line = in.readLine();
				}
			}
			catch (IOException e)
			{
				System.err.println("Failed to handle url " + urls.get(0) + "\n" + e.toString());
			}
		}
		return prices;
	}

	public Map<String, Map<String, List<String>>> getFinancials(String symbol)
	{
		Map<String, Map<String, List<String>>> financials = new HashMap<String, Map<String, List<String>>>();
		if (symbol != null)
		{
			symbol = symbol.trim();
			financials.put("income", this.getIncome(symbol));
			financials.put("balanceSheet", this.getBalanceSheet(symbol));
			financials.put("cashflow", this.getCashFlow(symbol));
		}
		return financials;
	}

	public Map<String, List<String>> getIncome(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}
		String url = "http://finance.yahoo.com/q/is?s=" + symbol + "+Income+Statement&annual";
		return toMap(crawler.retreive(url));
	}

	public Map<String, List<String>> getBalanceSheet(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}
		String url = "http://finance.yahoo.com/q/bs?s=" + symbol + "+Balance+Sheet&annual";
		return toMap(crawler.retreive(url));
	}

	public Map<String, List<String>> getCashFlow(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}
		String url = "http://finance.yahoo.com/q/cf?s=" + symbol + "+Cash+Flow&annual";
		return toMap(crawler.retreive(url));
	}

	public Map<String, String> getSummary(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}

		String url = "http://finance.yahoo.com/q?s=" + symbol.trim();
		return toSummary(crawler.retreive(url));
	}

	public Map<String, String> getKeyStats(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}
		String url = "http://finance.yahoo.com/q/ks?s=" + symbol.trim() + "+Key+Statistics";
		return toKeyStats(crawler.retreive(url));
	}

	public Map<String, String> getProfile(String symbol)
	{
		if (crawler == null)
		{
			crawler = new WebCrawler();
		}
		String url = "http://finance.yahoo.com/q/pr?s=" + symbol.trim() + "+Profile";
		return toProfile(crawler.retreive(url));
	}

	@Override
	public boolean isChildCrawlable(CrawlableEndpoint endPoint, Object childObject)
	{
		LinkTag linkTag = (LinkTag) childObject;
		Node relatedTickers = linkTag.getParent().getParent();
		if (relatedTickers instanceof Div)
		{
			String id = ((Div) relatedTickers).getAttribute("id");
			if ("yfi_related_tickers".equals(id))
			{
				return true;
			}
		}
		return false;
	}

	@Override
	public IndexableDocument createIndexableDocument(String url, Object content)
	{
		// IndexableDocument doc = process(url, (NodeList) content);
		if (content instanceof NodeList)
		{
			Company emp = new Company();
			emp.setName(getTitle((NodeList) content));

			emp.setId(GUIDUtil.getGUID(emp));

			// we need get profile here
			IndexableDocument doc = PersistenceManager.createDocument(emp);
			doc.overrideAccessURL(url);

			return doc;
		}
		else
		{
			return null;
		}
	}

	protected String getTitle(NodeList list)
	{
		NodeList rows = list.extractAllNodesThatMatch(new TagNameFilter("title"), true);
		if (rows.size() == 1)
		{
			TitleTag title = (TitleTag) rows.elementAt(0);
			return title.getTitle();
		}
		return "";
	}

	private void processChildren(NodeList list, Map<String, String> profile)
	{
		SimpleNodeIterator iter = list.elements();
		while (iter.hasMoreNodes())
		{
			Node childNode = iter.nextNode();
			if (childNode instanceof TextNode)
			{
				attributes.add(childNode.getText());
				count++;
			}

			if (childNode.getChildren() != null)
			{
				processChildren(childNode.getChildren(), profile);
			}
		}
	}

	private Map<String, String> toSummary(NodeList list)
	{
		Map<String, String> summary = new HashMap<String, String>();
		NodeList rows = list.extractAllNodesThatMatch(new HasAttributeFilter("class", "rtq_table"), true);
		NodeList properties = rows.extractAllNodesThatMatch(new TagNameFilter("tr"), true);
		SimpleNodeIterator propertyIterator = properties.elements();
		while (propertyIterator.hasMoreNodes())
		{
			Node tr = propertyIterator.nextNode();
			Node th = tr.getFirstChild();
			Node td = tr.getLastChild();
			summary.put(th.getFirstChild().toPlainTextString(), td.getFirstChild().toPlainTextString());
		}
		return summary;
	}

	private Map<String, String> toProfile(NodeList list)
	{
		Map<String, String> profile = new HashMap<String, String>();
		this.attributes.clear();
		NodeList rows = list.extractAllNodesThatMatch(new HasAttributeFilter("class", "yfnc_modtitlew1"), true);
		processChildren(rows, profile);
		NodeList attribute = list.extractAllNodesThatMatch(new HasAttributeFilter("class", "yfnc_datamodoutline1"), true);
		processChildren(attribute, profile);
		if (attributes.size() == 0)
		{
			// System.err.println("failed to get attributes " +
			// list.asString());
			return profile;
		}
		int i = 0;
		profile.put("name", attributes.get(i++));
		profile.put("address", attributes.get(i++));
		
		
		
		String cityAddr = attributes.get(i++);
		
		String[] addres = cityAddr.split(",");
		if (addres.length == 1)
		{
			profile.put("address1", cityAddr);
			cityAddr = attributes.get(i++);
		}
		addres = cityAddr.split(",");
		profile.put("city", addres[0]);
		if (addres.length == 2)
		{
			addres = addres[1].trim().split("\\ ");
			if (addres.length > 0)
			{
				profile.put("state", addres[0]);
			}
			if (addres.length > 1)
			{
				profile.put("zipCode", addres[1]);
			}
		}
		String countryStr = attributes.get(i++);
		if (countryStr != null && countryStr.contains("-"))
		{
			profile.put("country", countryStr.substring(0, countryStr.indexOf("-")).trim());
		}
		//done with address
		
		i = 0;
		for (String attr : attributes)
		{
			if (attr.toLowerCase().contains("phone:"))
			{
				profile.put("phone", attr.substring(attr.indexOf(":")+1).trim());
			}
			if (attr.toLowerCase().contains("fax:"))
			{
				profile.put("fax", attr.substring(attr.indexOf(":")+1).trim());
			}
			if (attr.toLowerCase().contains("http"))
			{
				profile.put("website", attr.trim());
			}
		}
		
		i = attributes.indexOf("Sector:");
		profile.put("sector", attributes.get(i + 1));

		i = attributes.indexOf("Industry:");
		profile.put("industry", attributes.get(i + 1));

		i = attributes.indexOf("Business Summary");
		profile.put("summary", attributes.get(i + 2));

		i = attributes.indexOf("Full Time Employees:");
		profile.put("numberOfEmployees", attributes.get(i + 1));

		// executives
		i = attributes.indexOf("Exercised");
		while (i + 3 < attributes.size())
		{
			profile.put(attributes.get(i + 3), attributes.get(i + 1));
			i += 5;
		}
		return profile;
	}

	@Override
	public GraphAnalyzer getGraphAnalyzer(String url)
	{
		return this;
	}

	public void setCrawler(Crawler crawler)
	{
		this.crawler = (WebCrawler) crawler;
	}

	public Crawler getCrawler()
	{
		return crawler;
	}

	private Map<String, String> toKeyStats(NodeList list)
	{
		Map<String, String> summary = new HashMap<String, String>();
		NodeList rows = list.extractAllNodesThatMatch(new HasAttributeFilter("class", "yfnc_datamodoutline1"), true);
		NodeList tables = rows.extractAllNodesThatMatch(new TagNameFilter("table"), true);
		NodeList tableRows = tables.extractAllNodesThatMatch(new TagNameFilter("tr"), true);
		SimpleNodeIterator propertyIterator = tableRows.elements();
		while (propertyIterator.hasMoreNodes())
		{
			Node tr = propertyIterator.nextNode();
			Node th = tr.getFirstChild();
			Node td = tr.getLastChild();
			if (!th.equals(td))
			{
				summary.put(th.getFirstChild().toPlainTextString(), td.getFirstChild().toPlainTextString());
			}
		}
		return summary;
	}

	public List<StockPrice> toPrices(String stockSymbol, NodeList list)
	{
		List<StockPrice> prices = new ArrayList<StockPrice>();
		NodeList tables = list.extractAllNodesThatMatch(new TagNameFilter("table"), true);
		NodeList tableRows = tables.extractAllNodesThatMatch(new TagNameFilter("tr"), true);
		SimpleNodeIterator propertyIterator = tableRows.elements();
		while (propertyIterator.hasMoreNodes())
		{
			TableRow tr = (TableRow) propertyIterator.nextNode();
			if (tr.getColumnCount() != 7)
			{
				continue;
			}
			else
			{
				StringBuffer line = new StringBuffer();
				TableColumn[] columns = tr.getColumns();
				line.append(StockPrice.dateFormat.format(this.mapValueUtil.getDate(columns[0].toPlainTextString()))).append(",");
				line.append(columns[1].toPlainTextString()).append(",");
				line.append(columns[2].toPlainTextString()).append(",");
				line.append(columns[3].toPlainTextString()).append(",");
				line.append(columns[4].toPlainTextString()).append(",");
				line.append(columns[5].toPlainTextString()).append(",");
				line.append(columns[6].toPlainTextString());
				prices.add(new StockPrice(stockSymbol, line.toString()));
			}
		}
		return prices;
	}

	private List<String> toUrls(NodeList list)
	{
		List<String> urls = new ArrayList<String>();
		NodeList tableRows = list.extractAllNodesThatMatch(new TagNameFilter("a"), true);
		SimpleNodeIterator propertyIterator = tableRows.elements();
		while (propertyIterator.hasMoreNodes())
		{
			Node tr = propertyIterator.nextNode();
			String url = ((Tag) tr).getAttribute("href");
			if (url.contains(".csv"))
			{
				urls.add(url);
			}
		}
		return urls;
	}

	private Map<String, List<String>> toMap(NodeList list)
	{
		Map<String, List<String>> summary = new HashMap<String, List<String>>();
		NodeList tableRows = list.extractAllNodesThatMatch(new TagNameFilter("tr"), true);
		SimpleNodeIterator propertyIterator = tableRows.elements();
		while (propertyIterator.hasMoreNodes())
		{
			TableRow tr = (TableRow) propertyIterator.nextNode();
			if (tr.getHeaderCount() > 0 && tr.getColumnCount() == 1)
			{
				TableColumn col = tr.getColumns()[0];
				TableHeader[] columns = tr.getHeaders();
				List<String> values = new ArrayList<String>();
				for (int i = 0; i < columns.length; i++)
				{
					values.add(columns[i].toPlainTextString().replaceAll("&nbsp;", "").trim());

				}
				summary.put(col.toPlainTextString().trim(), values);
			}
			else if (tr.getColumnCount() >= 4)
			{
				TableColumn[] columns = tr.getColumns();
				int colCount = tr.getColumnCount();
				int startCount = colCount == 4 ? 0 : 1;
				TableColumn th = columns[startCount];
				List<String> values = new ArrayList<String>();

				for (int i = startCount + 1; i < colCount; i++)
				{
					values.add(columns[i].toPlainTextString().replaceAll("&nbsp;", "").trim());
				}
				summary.put(th.toPlainTextString().trim(), values);
			}
		}
		return summary;
	}

	public Stock getCompany()
	{
		return company;
	}

	public void setCompany(Stock company)
	{
		this.company = company;
	}

	private Stock company;

	@Override
	public void run()
	{
		if (company != null)
		{
			this.enrich(company);
		}
		busy = false;
	}
}
