package org.sixstreams.search.crawl.web;

import java.io.InputStream;

import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.sixstreams.search.Crawlable;
import org.sixstreams.search.crawl.crawler.AbstractCrawler;
import org.sixstreams.search.crawl.crawler.CacheManager;
import org.sixstreams.search.crawl.crawler.ContentMapper;
import org.sixstreams.search.crawl.crawler.CrawlableEndpoint;
import org.sixstreams.search.crawl.crawler.CrawlableImpl;
import org.sixstreams.search.crawl.crawler.GraphAnalyzer;
import org.sixstreams.search.meta.MetaDataManager;

import org.htmlparser.Node;
import org.htmlparser.Parser;
import org.htmlparser.http.ConnectionManager;
import org.htmlparser.http.ConnectionMonitor;
import org.htmlparser.http.HttpHeader;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.NodeList;

public class WebCrawler extends AbstractCrawler
{
	public static final String MAX_LEVEL_PROPERTY_KEY = "org.sixstreams.search.web.crawler.WebCrawler.MaxLevel";
	private static final String CONTENT_TYPE_HTML_TEXT = "text/html";

	private static Logger sLogger = Logger.getLogger(WebCrawler.class.getName());
	private static Map<String, String> sFailedUrls = new HashMap<String, String>();

	private CacheManager cacheManager = new CacheManager();

	private int maxLevel = -1;

	private Parser parser;

	private String proxyHost;
	private int proxyPort;

	public WebCrawler()
	{
		String maxLevel = MetaDataManager.getProperty(MAX_LEVEL_PROPERTY_KEY);
		if (maxLevel != null)
		{
			this.maxLevel = Integer.parseInt(maxLevel);
		}
	}

	private void initializeConnectionManager()
	{
		ConnectionManager manager = Parser.getConnectionManager();
		CookieHandler.setDefault(new CookieManager(null, CookiePolicy.ACCEPT_ALL));
		if (proxyHost != null)
		{
			manager.setProxyHost(proxyHost);
			manager.setProxyPort(proxyPort);
		}

		if (sLogger.isLoggable(Level.FINE))
		{
			ConnectionMonitor monitor = new ConnectionMonitor()
			{
				public void preConnect(HttpURLConnection connection)
				{
					sLogger.fine(HttpHeader.getRequestHeader(connection));
				}

				public void postConnect(HttpURLConnection connection)
				{
					sLogger.fine(HttpHeader.getResponseHeader(connection));
				}
			};
			manager.setMonitor(monitor);
		}
	}

	public InputStream read(String urlString)
	{
		try
		{
			URL url = new URL(cacheManager.cachedUrl(urlString));
			URLConnection urlConnection = url.openConnection();
			return urlConnection.getInputStream();
		}
		catch (Throwable e)
		{
			failedOn(urlString, e);
		}
		return null;
	}

	public NodeList retreive(String urlString)
	{
		try
		{
			initializeConnectionManager();
			parser = new Parser(cacheManager.cachedUrl(urlString));
			NodeList nodes = parser.parse(null);
			return nodes;
		}
		catch (Throwable e)
		{
			failedOn(urlString, e);
		}
		return null;
	}

	public Crawlable retreive(CrawlableEndpoint endpoint)
	{
		String url = endpoint.getUrl();
		try
		{
			NodeList list = retreive(url);
			CrawlableImpl crawlable = null;

			if (maxLevel > endpoint.getLevel() || maxLevel == -1)
			{
				crawlable = new CrawlableImpl(this, url, getChildUrls(endpoint, list), list);
			}
			else
			{
				crawlable = new CrawlableImpl(this, url, null, list);
			}

			String contentType = (String) getContextParam(AbstractCrawler.CONTENT_TYPE_KEY);

			if (contentType != null)
			{
				crawlable.setContentType(contentType);
			}
			else
			{
				crawlable.setContentType(CONTENT_TYPE_HTML_TEXT);
			}
			return crawlable;
		}
		catch (Throwable e)
		{
			endpoint.setError(e);
			failedOn(url, e);
		}
		return null;
	}

	protected boolean isUrlCrawlable(String url)
	{
		return url != null && !url.isEmpty();
	}

	protected GraphAnalyzer getGraphAnalyzer(Object object)
	{
		String url = "" + object;
		if (object instanceof LinkTag)
		{
			url = ((LinkTag) object).getLink();
			return super.getGraphAnalyzer(url);
		}
		else
		{
			return null;
		}
	}

	protected List<String> getChildUrls(CrawlableEndpoint endpoint, NodeList list)
	{
		List<String> urls = new ArrayList<String>();
		NodeList text = list.extractAllNodesThatMatch(new LinkFilterImpl(), true);
		for (Node node : text.toNodeArray())
		{
			LinkTag linkTag = (LinkTag) node;

			if (isObjectCrawlable(endpoint, linkTag))
			{
				String urlString = linkTag.getLink();
				if (isUrlCrawlable(urlString))
				{
					urls.add(urlString);
				}
			}
		}

		return urls;
	}

	private void failedOn(String url, Throwable t)
	{
		if (sFailedUrls.get(url) != null)
		{
			return;
		}
		sFailedUrls.put(url, url);
		System.err.println("Failed on " + url);
		t.printStackTrace();
	}

	public String getStartingUrl()
	{

		return (String) getContextParam(URL_KEY);
	}

	protected ContentMapper getContentMapper()
	{
		return new WebPageMapper();
	}

	public void setMaxLevel(int mMaxLevel)
	{
		this.maxLevel = mMaxLevel;
	}

	public int getMaxLevel()
	{
		return maxLevel;
	}

	public void setProxyHost(String mProxyHost)
	{
		this.proxyHost = mProxyHost;
	}

	public String getProxyHost()
	{
		return proxyHost;
	}

	public void setProxyPort(int mProxyPort)
	{
		this.proxyPort = mProxyPort;
	}

	public int getProxyPort()
	{
		return proxyPort;
	}
}
