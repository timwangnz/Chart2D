package org.sixstreams.app.marketIntel;

import java.util.Date;
import java.util.List;

import org.sixstreams.app.data.Company;
import org.sixstreams.search.SearchException;
import org.sixstreams.search.data.PersistenceManager;
import org.sixstreams.search.data.java.annotations.Searchable;
@Searchable(title = "name")
public class Stock extends Company
{
	private String sourceUrl;
	private float targetPrice;
	private float averageVolume;
	private float yield;
	private float enterpriseValue;
	private float forwardPE;
	private float trailingPE;
	private float price;
	private float sales;
	private float bookValue;
	private float ebitda; // earning before interes, taxes depreciatiation and
							// amortization
	private String fiscalYear;
	private float profitMargin;
	private float opratingMargin;
	private float returnOnAssets;
	private float returnOnEquity;
	private float revenuePerShare;
	private float grossProfit;
	private float netIncome;
	private float dilutedEPS;

	private float totalCash;
	private float totalDebt;

	private float totalDebtOverEquity;
	private float currentRatio;
	private float bookValuePerShare;

	private float cachFlow;
	private float leveredFreeCachFlow;

	private float beta;
	private float highIn52;
	private float lowIn52;
	private float movingAverageIn50;
	private float movingAverageIn200;
	private float sharesOutstanding;
	private float sharesFloat;
	private float holdByInsiders;
	private float holdByInstitutions;
	private float sharesShort;

	private float dividend;
	private float payoutRatio;
	private Date dividendDate;

	private float PEGRatio;
	private float priceOverSales;
	private float priceOverBook;
	private float enterpriseValueOverRevenue;
	private float enterpriseValueOverEDITDA;
	private Date mostRecentQuarter;
	private float revenueGrowth;

	private float netIncomeForCommon;
	private float earningsGrowth;
	private float totalCashPerShare;
	private float debtOverEquity;
	private float opratingCashflow;
	private float leveredFreeCashflow;
	private float changeIn52Weeks;
	private float averageVolumeIn3Months;

	private float averageVolumeIn10Days;
	private float shortRatio;
	private float shortRatioOnFloat;
	private float dividendYield;
	private Date exDividendDate;
	private float lastSplitFactor;
	private Date lastSplitDate;
	private Date nextEaringDate;

	private String stockType;

	public void setTargetPrice(float targetPrice)
	{
		this.targetPrice = targetPrice;
	}

	public float getTargetPrice()
	{
		return targetPrice;
	}

	public static List<Stock> getStocks(String query, int start, int limit) throws SearchException
	{
		PersistenceManager pm = new PersistenceManager();
		return pm.query(query, Stock.class, start, limit);
	}
	/*
	//wrapping methods
	private static String STOCK_SYMBOL_FIELD_NAME = "stockSymbol";
	
	private PersistenceManager pm = new PersistenceManager();
	
	private Map<String, Object> getSymbolFilter()
	{
		Map<String, Object> filter = new HashMap<String, Object>();
		filter.put(STOCK_SYMBOL_FIELD_NAME, this.getStockSymbol());
		return filter;
	}

	public List<IncomeStatement> getIncomeStatements() throws SearchException
	{
		
		return pm.query(getSymbolFilter(), IncomeStatement.class);
	}

	public List<BalanceSheet> getBalanceSheet() throws SearchException
	{
		return pm.query(getSymbolFilter(), BalanceSheet.class);

	}
	
	public List<Cashflow> getCashflow() throws SearchException
	{
		return pm.query(getSymbolFilter(), Cashflow.class);
	}

	public List<StockPrice> getStockPrices() throws SearchException
	{
		return pm.query(getSymbolFilter(), StockPrice.class);
	}
*/
	public void setAverageVolume(float averageVolume)
	{
		this.averageVolume = averageVolume;
	}

	public float getAverageVolume()
	{
		return averageVolume;
	}

	public void setYield(float yield)
	{
		this.yield = yield;
	}

	public float getYield()
	{
		return yield;
	}

	public void setEnterpriseValue(float enterpriseValue)
	{
		this.enterpriseValue = enterpriseValue;
	}

	public float getEnterpriseValue()
	{
		return enterpriseValue;
	}

	public void setForwardPE(float forwardPE)
	{
		this.forwardPE = forwardPE;
	}

	public float getForwardPE()
	{
		return forwardPE;
	}

	public void setTrailingPE(float trailingPE)
	{
		this.trailingPE = trailingPE;
	}

	public float getTrailingPE()
	{
		return trailingPE;
	}

	public void setPrice(float price)
	{
		this.price = price;
	}

	public float getPrice()
	{
		return price;
	}

	public void setSales(float sales)
	{
		this.sales = sales;
	}

	public float getSales()
	{
		return sales;
	}

	public void setBookValue(float bookValue)
	{
		this.bookValue = bookValue;
	}

	public float getBookValue()
	{
		return bookValue;
	}

	public void setEbitda(float ebitda)
	{
		this.ebitda = ebitda;
	}

	public float getEbitda()
	{
		return ebitda;
	}

	public void setFiscalYear(String fiscalYear)
	{
		this.fiscalYear = fiscalYear;
	}

	public String getFiscalYear()
	{
		return fiscalYear;
	}

	public void setProfitMargin(float profitMargin)
	{
		this.profitMargin = profitMargin;
	}

	public float getProfitMargin()
	{
		return profitMargin;
	}

	public void setOpratingMargin(float opratingMargin)
	{
		this.opratingMargin = opratingMargin;
	}

	public float getOpratingMargin()
	{
		return opratingMargin;
	}

	public void setReturnOnAssets(float returnOnAssets)
	{
		this.returnOnAssets = returnOnAssets;
	}

	public float getReturnOnAssets()
	{
		return returnOnAssets;
	}

	public void setReturnOnEquity(float returnOnEquity)
	{
		this.returnOnEquity = returnOnEquity;
	}

	public float getReturnOnEquity()
	{
		return returnOnEquity;
	}

	public void setRevenuePerShare(float revenuePerShare)
	{
		this.revenuePerShare = revenuePerShare;
	}

	public float getRevenuePerShare()
	{
		return revenuePerShare;
	}

	public void setGrossProfit(float grossProfit)
	{
		this.grossProfit = grossProfit;
	}

	public float getGrossProfit()
	{
		return grossProfit;
	}

	public void setNetIncome(float netIncome)
	{
		this.netIncome = netIncome;
	}

	public float getNetIncome()
	{
		return netIncome;
	}

	public void setDilutedEPS(float dilutedEPS)
	{
		this.dilutedEPS = dilutedEPS;
	}

	public float getDilutedEPS()
	{
		return dilutedEPS;
	}

	public void setTotalCash(float totalCash)
	{
		this.totalCash = totalCash;
	}

	public float getTotalCash()
	{
		return totalCash;
	}

	public void setTotalDebt(float totalDebt)
	{
		this.totalDebt = totalDebt;
	}

	public float getTotalDebt()
	{
		return totalDebt;
	}

	public void setTotalDebtOverEquity(float totalDebtOverEquity)
	{
		this.totalDebtOverEquity = totalDebtOverEquity;
	}

	public float getTotalDebtOverEquity()
	{
		return totalDebtOverEquity;
	}

	public void setCurrentRatio(float currentRatio)
	{
		this.currentRatio = currentRatio;
	}

	public float getCurrentRatio()
	{
		return currentRatio;
	}

	public void setBookValuePerShare(float bookValuePerShare)
	{
		this.bookValuePerShare = bookValuePerShare;
	}

	public float getBookValuePerShare()
	{
		return bookValuePerShare;
	}

	public void setCachFlow(float cachFlow)
	{
		this.cachFlow = cachFlow;
	}

	public float getCachFlow()
	{
		return cachFlow;
	}

	public void setLeveredFreeCachFlow(float leveredFreeCachFlow)
	{
		this.leveredFreeCachFlow = leveredFreeCachFlow;
	}

	public float getLeveredFreeCachFlow()
	{
		return leveredFreeCachFlow;
	}

	public void setBeta(float beta)
	{
		this.beta = beta;
	}

	public float getBeta()
	{
		return beta;
	}

	public void setHighIn52(float highIn52)
	{
		this.highIn52 = highIn52;
	}

	public float getHighIn52()
	{
		return highIn52;
	}

	public void setLowIn52(float lowIn52)
	{
		this.lowIn52 = lowIn52;
	}

	public float getLowIn52()
	{
		return lowIn52;
	}

	public void setMovingAverageIn50(float movingAverageIn50)
	{
		this.movingAverageIn50 = movingAverageIn50;
	}

	public float getMovingAverageIn50()
	{
		return movingAverageIn50;
	}

	public void setMovingAverageIn200(float movingAverageIn200)
	{
		this.movingAverageIn200 = movingAverageIn200;
	}

	public float getMovingAverageIn200()
	{
		return movingAverageIn200;
	}

	public void setSharesOutstanding(float sharesOutstanding)
	{
		this.sharesOutstanding = sharesOutstanding;
	}

	public float getSharesOutstanding()
	{
		return sharesOutstanding;
	}

	public void setSharesFloat(float sharesFloat)
	{
		this.sharesFloat = sharesFloat;
	}

	public float getSharesFloat()
	{
		return sharesFloat;
	}

	public void setHoldByInsiders(float holdByInsiders)
	{
		this.holdByInsiders = holdByInsiders;
	}

	public float getHoldByInsiders()
	{
		return holdByInsiders;
	}

	public void setHoldByInstitutions(float holdByInstitutions)
	{
		this.holdByInstitutions = holdByInstitutions;
	}

	public float getHoldByInstitutions()
	{
		return holdByInstitutions;
	}

	public void setSharesShort(float sharesShort)
	{
		this.sharesShort = sharesShort;
	}

	public float getSharesShort()
	{
		return sharesShort;
	}

	public void setDividend(float dividend)
	{
		this.dividend = dividend;
	}

	public float getDividend()
	{
		return dividend;
	}

	public void setPayoutRatio(float payoutRatio)
	{
		this.payoutRatio = payoutRatio;
	}

	public float getPayoutRatio()
	{
		return payoutRatio;
	}

	public void setDividendDate(Date dividendDate)
	{
		this.dividendDate = dividendDate;
	}

	public Date getDividendDate()
	{
		return dividendDate;
	}

	public void setPEGRatio(float PEGRatio)
	{
		this.PEGRatio = PEGRatio;
	}

	public float getPEGRatio()
	{
		return PEGRatio;
	}

	public void setPriceOverSales(float priceOverSales)
	{
		this.priceOverSales = priceOverSales;
	}

	public float getPriceOverSales()
	{
		return priceOverSales;
	}

	public void setPriceOverBook(float priceOverBook)
	{
		this.priceOverBook = priceOverBook;
	}

	public float getPriceOverBook()
	{
		return priceOverBook;
	}

	public void setEnterpriseValueOverRevenue(float enterpriseValueOverRevenue)
	{
		this.enterpriseValueOverRevenue = enterpriseValueOverRevenue;
	}

	public float getEnterpriseValueOverRevenue()
	{
		return enterpriseValueOverRevenue;
	}

	public void setEnterpriseValueOverEDITDA(float enterpriseValueOverEDITDA)
	{
		this.enterpriseValueOverEDITDA = enterpriseValueOverEDITDA;
	}

	public float getEnterpriseValueOverEDITDA()
	{
		return enterpriseValueOverEDITDA;
	}

	public void setMostRecentQuarter(Date mostRecentQuarter)
	{
		this.mostRecentQuarter = mostRecentQuarter;
	}

	public Date getMostRecentQuarter()
	{
		return mostRecentQuarter;
	}

	public void setRevenueGrowth(float revenueGrowth)
	{
		this.revenueGrowth = revenueGrowth;
	}

	public float getRevenueGrowth()
	{
		return revenueGrowth;
	}

	public void setNetIncomeForCommon(float netIncomeForCommon)
	{
		this.netIncomeForCommon = netIncomeForCommon;
	}

	public float getNetIncomeForCommon()
	{
		return netIncomeForCommon;
	}

	public void setEarningsGrowth(float earningsGrowth)
	{
		this.earningsGrowth = earningsGrowth;
	}

	public float getEarningsGrowth()
	{
		return earningsGrowth;
	}

	public void setTotalCashPerShare(float totalCashPerShare)
	{
		this.totalCashPerShare = totalCashPerShare;
	}

	public float getTotalCashPerShare()
	{
		return totalCashPerShare;
	}

	public void setDebtOverEquity(float debtOverEquity)
	{
		this.debtOverEquity = debtOverEquity;
	}

	public float getDebtOverEquity()
	{
		return debtOverEquity;
	}

	public void setOpratingCashflow(float opratingCashflow)
	{
		this.opratingCashflow = opratingCashflow;
	}

	public float getOpratingCashflow()
	{
		return opratingCashflow;
	}

	public void setLeveredFreeCashflow(float leveredFreeCashflow)
	{
		this.leveredFreeCashflow = leveredFreeCashflow;
	}

	public float getLeveredFreeCashflow()
	{
		return leveredFreeCashflow;
	}

	public void setChangeIn52Weeks(float changeIn52Weeks)
	{
		this.changeIn52Weeks = changeIn52Weeks;
	}

	public float getChangeIn52Weeks()
	{
		return changeIn52Weeks;
	}

	public void setAverageVolumeIn3Months(float averageVolumeIn3Months)
	{
		this.averageVolumeIn3Months = averageVolumeIn3Months;
	}

	public float getAverageVolumeIn3Months()
	{
		return averageVolumeIn3Months;
	}

	public void setAverageVolumeIn10Days(float averageVolumeIn10Days)
	{
		this.averageVolumeIn10Days = averageVolumeIn10Days;
	}

	public float getAverageVolumeIn10Days()
	{
		return averageVolumeIn10Days;
	}

	public void setShortRatio(float shortRatio)
	{
		this.shortRatio = shortRatio;
	}

	public float getShortRatio()
	{
		return shortRatio;
	}

	public void setShortRatioOnFloat(float shortRatioOnFloat)
	{
		this.shortRatioOnFloat = shortRatioOnFloat;
	}

	public float getShortRatioOnFloat()
	{
		return shortRatioOnFloat;
	}

	public void setDividendYield(float dividendYield)
	{
		this.dividendYield = dividendYield;
	}

	public float getDividendYield()
	{
		return dividendYield;
	}

	public void setExDividendDate(Date exDividendDate)
	{
		this.exDividendDate = exDividendDate;
	}

	public Date getExDividendDate()
	{
		return exDividendDate;
	}

	public void setLastSplitFactor(float lastSplitFactor)
	{
		this.lastSplitFactor = lastSplitFactor;
	}

	public float getLastSplitFactor()
	{
		return lastSplitFactor;
	}

	public void setLastSplitDate(Date lastSplitDate)
	{
		this.lastSplitDate = lastSplitDate;
	}

	public Date getLastSplitDate()
	{
		return lastSplitDate;
	}

	public void setNextEaringDate(Date nextEaringDate)
	{
		this.nextEaringDate = nextEaringDate;
	}

	public Date getNextEaringDate()
	{
		return nextEaringDate;
	}

	public void setStockType(String stockType)
	{
		this.stockType = stockType;
	}

	public String getStockType()
	{

		return stockType;
	}

	public void setSourceUrl(String sourceUrl)
	{
		this.sourceUrl = sourceUrl;
	}

	public String getSourceUrl()
	{
		return sourceUrl;
	}

	public String toString()
	{
		return BeanPrinter.toString(this);
	}
}
