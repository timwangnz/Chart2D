package org.sixstreams.app.data.crawlers.yahoo;

import java.math.BigDecimal;

import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.sixstreams.app.marketIntel.BalanceSheet;
import org.sixstreams.app.marketIntel.Cashflow;
import org.sixstreams.app.marketIntel.IncomeStatement;
import org.sixstreams.app.marketIntel.Stock;

public class MapValueUtil
{
   DecimalFormat numberFormat = new DecimalFormat("#,###");
   DateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
   public List<IncomeStatement> createIncomeStatements(Stock stock, Map<String, List<String>> lineItem)
   {
      String stockSymbol = stock.getStockSymbol();
      List<String> dates = lineItem.get("Period Ending");
      //revenue
      List<Float> totalRevenue = getFloats(lineItem, "total revenue");
      //must have revenue to create income statement, for funds, there might be no total revenue;
      if(totalRevenue.size() == 0)   
      {
         return Collections.emptyList();
      }
      
      List<Float> costOfRevenue = getFloats(lineItem, "Cost of Revenue");
      List<Float> grossProfit = getFloats(lineItem, "Gross Profit");

      //expenses
      List<Float> resAndDev = getFloats(lineItem, "Research Development");
      List<Float> sellingAdmin = getFloats(lineItem, "Selling General and Administrative");
      List<Float> nonRecurring = getFloats(lineItem, "Non Recurring");
      List<Float> totOpExp = getFloats(lineItem, "Total Operating Expenses");
      //op income
      List<Float> opInc = getFloats(lineItem, "Operating Income or Loss");

      //cont income       
      List<Float> totalOtherIncome = getFloats(lineItem, "Total Other Income");
      List<Float> earningsBeforeIT = getFloats(lineItem, "Earnings Before Interest And Taxes");
      List<Float> interestExpense = getFloats(lineItem, "Interest Expense");
      List<Float> incomeBeforeT = getFloats(lineItem, "Income Before Tax");
      List<Float> incomeTax = getFloats(lineItem, "Income Tax Expense");
      List<Float> minorityInterest = getFloats(lineItem, "Minority Interest");
      List<Float> continuingInc = getFloats(lineItem, "Net Income From Continuing Ops");
      //non recurring
      List<Float> discontinuedOperations = getFloats(lineItem, "Discontinued Operations");
      List<Float> extraordinaryItems = getFloats(lineItem, "Extraordinary Items");
      List<Float> effectOfAcctChanges = getFloats(lineItem, "Effect Of Accounting Changes");
      List<Float> otherItems = getFloats(lineItem, "Other Items");
      
      //net
      List<Float> netIncome = getFloats(lineItem, "net income");
      List<Float> preferredStockAndAdjustments = getFloats(lineItem, "Preferred Stock And Other Adjustments");
      List<Float> niatocs = getFloats(lineItem, "Net Income Applicable To Common Shares");

      List<IncomeStatement> statements = new ArrayList<IncomeStatement> ();
      for (int i = 0; i < dates.size(); i++)
      {
         IncomeStatement stockIncome = new IncomeStatement();
         stockIncome.setStockSymbol(stockSymbol);
         
         Date date = getDate(dates.get(i));
         //stockIncome.setId(stockSymbol + "-" + date.getTime());
         stockIncome.setDate(date);
         
         stockIncome.setTotalRevenue(totalRevenue.get(i));
         stockIncome.setCostOfRevenue(costOfRevenue.get(i));
         stockIncome.setGrossProfit(grossProfit.get(i));

         stockIncome.setResearchAndDevelopment(resAndDev.get(i));
         stockIncome.setSellingAndAdmin(sellingAdmin.get(i));
         stockIncome.setNoneRecurring(nonRecurring.get(i));
         stockIncome.setTotalOperatingExpenses(totOpExp.get(i));
         stockIncome.setOperatingIncome(opInc.get(i));
         
         stockIncome.setOtherIncome(totalOtherIncome.get(i));
         stockIncome.setEarningsBeforeIT(earningsBeforeIT.get(i));
         stockIncome.setInterestExpense(interestExpense.get(i));
         stockIncome.setIncomeBeforeTax(incomeBeforeT.get(i));
         stockIncome.setIncomeTax(incomeTax.get(i));
         stockIncome.setMinorityInterest(minorityInterest.get(i));
         stockIncome.setNetIncomeForCommon(continuingInc.get(i));

         stockIncome.setDiscontinuedOperations(discontinuedOperations.get(i));
         stockIncome.setExtraordinaryItems(extraordinaryItems.get(i));
         stockIncome.setEffectOfAccoutingChanges(effectOfAcctChanges.get(i));
         stockIncome.setOtherItems(otherItems.get(i));
         stockIncome.setNetIncome(netIncome.get(i));
         stockIncome.setPreferredStock(preferredStockAndAdjustments.get(i));
         stockIncome.setNetIncomeForCommon(niatocs.get(i));
         statements.add(stockIncome);
      }
      return statements;
   }
   
   public List<BalanceSheet> createBalanceSheets(Stock stock, Map<String, List<String>> lineItem)
   {
      String stockSymbol = stock.getStockSymbol();
      List<String> dates = lineItem.get("Period Ending");
       
      List<BalanceSheet> balanceSheets = new ArrayList<BalanceSheet> ();
      //assets
      //current assets
      List<Float> cash = getFloats(lineItem, "Cash And Cash Equivalents");
      //must have cash or it would be not a company
      if (cash.size() == 0)
      {
         return balanceSheets;
      }
      List<Float> shortTermInv = getFloats(lineItem, "Short Term Investments");
      List<Float> netReceivable = getFloats(lineItem, "Net Receivables");
      List<Float> inventory = getFloats(lineItem, "Inventory");
      List<Float> otherCurrentAssets = getFloats(lineItem, "Other Current Assets");
      List<Float> totalCurrentAssets = getFloats(lineItem, "Total Current Assets");
   
      //long term
      List<Float> lontTermInv = getFloats(lineItem, "Long Term Investments");
      List<Float> propertyPlantAndEquipment = getFloats(lineItem, "Property Plant and Equipment");
      List<Float> goodwill = getFloats(lineItem, "Goodwill");
      List<Float> intangibleAssets = getFloats(lineItem, "Intangible Assets");
      List<Float> accumulatedAmortization = getFloats(lineItem, "Accumulated Amortization");
      List<Float> otherAssets = getFloats(lineItem, "Other Assets");
      List<Float> deferredLongTermAssetCharges = getFloats(lineItem, "Deferred Long Term Asset Charges");
      List<Float> totalAssets = getFloats(lineItem, "Total Assets");

      //liabilities
      //current Liablities
      List<Float> accountPayable = getFloats(lineItem, "Accounts Payable");
      List<Float> shortTermDebt = getFloats(lineItem, "Short/Current Long Term Debt");
      List<Float> otherCurrentLiabilities = getFloats(lineItem, "Other Current Liabilities");
      List<Float> totalCurrentLiabilities = getFloats(lineItem, "Total Current Liabilities");
      
      List<Float> lontTermDebt = getFloats(lineItem, "Long Term Debt");
      List<Float> otherLiabilities = getFloats(lineItem, "Other Liabilities");
      List<Float> deferredLongTermliabilityCharge = getFloats(lineItem, "Deferred Long Term Liability Charges");
      List<Float> minorityIntrest = getFloats(lineItem, "Minority Interest");
      List<Float> negativeGoodwill = getFloats(lineItem, "Negative Goodwill");

      //share holder's equity
      List<Float> miscStocksOptionsWarrants = getFloats(lineItem, "Misc Stocks Options Warrants");
      List<Float> redeemablePreferredStock = getFloats(lineItem, "Redeemable Preferred Stock");
      List<Float> preferredStock = getFloats(lineItem, "Preferred Stock");
      List<Float> commonStock = getFloats(lineItem, "Common Stock");
      List<Float> retainedEarings = getFloats(lineItem, "Retained Earnings");
      List<Float> treasuryStock = getFloats(lineItem, "Treasury Stock");
      List<Float> capitalSurplus = getFloats(lineItem, "Capital Surplus");
      List<Float> otherStockholderEquity = getFloats(lineItem, "Other Stockholder Equity");
      List<Float> totalStockholderEquity = getFloats(lineItem, "Total Stockholder Equity");
      List<Float> netTangibleAssets = getFloats(lineItem, "Net Tangible Assets");
      
      for (int i = 0; i < dates.size(); i++)
      {
          BalanceSheet balanceSheet = new BalanceSheet();
         balanceSheet.setStockSymbol(stockSymbol);
         Date date = getDate(dates.get(i));
         //balanceSheet.setId(stockSymbol + "-" + date.getTime());
         balanceSheet.setDate(date);
         
         balanceSheet.setCash(cash.get(i));
         balanceSheet.setShortTermInvestments(shortTermInv.get(i));
         balanceSheet.setNetReceivables(netReceivable.get(i));
         balanceSheet.setInventory(inventory.get(i));
         balanceSheet.setOtherCurrentAssets(otherCurrentAssets.get(i));
         balanceSheet.setTotalCurrentAssets(totalCurrentAssets.get(i));
         

         balanceSheet.setLongTermInvestments(lontTermInv.get(i));
         balanceSheet.setPropertyPlantAndEquipment(propertyPlantAndEquipment.get(i));
         balanceSheet.setGoodWill(goodwill.get(i));
         balanceSheet.setIntangibleAssets(intangibleAssets.get(i));
         balanceSheet.setAmortization(accumulatedAmortization.get(i));
         balanceSheet.setOtherAssets(otherAssets.get(i));
         balanceSheet.setDeferredLongTermAssetCharges(deferredLongTermAssetCharges.get(i));
         balanceSheet.setTotalAssets(totalAssets.get(i));         
         
         balanceSheet.setAccountsPayable(accountPayable.get(i));
         balanceSheet.setShortTermDebt(shortTermDebt.get(i));
         balanceSheet.setOtherCurrentLiabilities(otherCurrentLiabilities.get(i));
         balanceSheet.setTotalCurrentLiabilities(totalCurrentLiabilities.get(i));
         balanceSheet.setLongTermDebt(lontTermDebt.get(i));
         balanceSheet.setOtherLiabilities(otherLiabilities.get(i));
         balanceSheet.setDeferredLongTermLiabilityCharges(deferredLongTermliabilityCharge.get(i));
         balanceSheet.setMinorityInterest(minorityIntrest.get(i));
         balanceSheet.setNegativeGoodwill(negativeGoodwill.get(i));
         
         balanceSheet.setMiscStocksOptionsWarrants(miscStocksOptionsWarrants.get(i));
         balanceSheet.setRedeemablePreferredStock(redeemablePreferredStock.get(i));
         balanceSheet.setPreferredStock(preferredStock.get(i));
         balanceSheet.setCommonStock(commonStock.get(i));
         balanceSheet.setRetainedEarnings(retainedEarings.get(i));
         balanceSheet.setTreasureStock(treasuryStock.get(i));
         balanceSheet.setCapitalSurplus(capitalSurplus.get(i));
         balanceSheet.setOtherStockholderEquity(otherStockholderEquity.get(i));
         balanceSheet.setTotalStockholderEquity(totalStockholderEquity.get(i));
         balanceSheet.setNetTangibleAssets(netTangibleAssets.get(i));         
         
         balanceSheets.add(balanceSheet);
      }
      return balanceSheets;
   }
   public List<Cashflow> createCashflows(Stock stock, Map<String, List<String>> lineItem)
   {
      String stockSymbol = stock.getStockSymbol();
      List<String> dates = lineItem.get("Period Ending");

      
      List<Cashflow> cashflows = new ArrayList<Cashflow> ();
      List<Float> netIncome = getFloats(lineItem, "Net Income");
      //must have cash or it would be not a company
      if (netIncome.size() == 0)
      {
         stock.setStockType("fund");
         return cashflows;
      }
      else
      {
         stock.setStockType("company");
      }

      List<Float> depreciation = getFloats(lineItem, "Depreciation");
      List<Float> adjustmentsToNetIncome = getFloats(lineItem, "Adjustments To Net Income");
      List<Float> changesInAccountsReceivables = getFloats(lineItem, "Changes In Accounts Receivables");
      List<Float> changesInLiabilities = getFloats(lineItem, "Changes In Liabilities");
      List<Float> changesInInventories = getFloats(lineItem, "Changes In Inventories");
      List<Float> changesInOtherOperatingAcitivities = getFloats(lineItem, "Changes In Other Operating Activities");
      List<Float> totalCashflowFromOperatingActivities = getFloats(lineItem, "Total Cash Flow From Operating Activities");
      List<Float> captialExpenditures = getFloats(lineItem, "Capital Expenditures");
      List<Float> investments = getFloats(lineItem, "Investments");
      List<Float> otherCashflowsFromInvestmentActivities = getFloats(lineItem, "Other Cash flows from Investing Activities");
      List<Float> totalCashflowFromInvestmentActivities = getFloats(lineItem, "Total Cash Flows From Investing Activities");
      List<Float> dividendsPaid = getFloats(lineItem, "Dividends Paid");
      List<Float> salePurchaseOfStock = getFloats(lineItem, "Sale Purchase of Stock");
      List<Float> netBorrowing = getFloats(lineItem, "Net Borrowings");
      List<Float> otherCashFlowsFromFinancingActivities = getFloats(lineItem, "Other Cash Flows from Financing Activities");
      List<Float> totalCashflowsFromFinancingActivities = getFloats(lineItem, "Total Cash Flows From Financing Activities");
      List<Float> effectOfExchangeRateChanges = getFloats(lineItem, "Effect Of Exchange Rate Changes");
      List<Float> changeInCashAndCashEquivalents = getFloats(lineItem, "Change In Cash and Cash Equivalents");
      

      for (int i = 0; i < dates.size(); i++)
      {
         
         Cashflow cashflow = new Cashflow();
         cashflow.setStockSymbol(stockSymbol);
         
         Date date = getDate(dates.get(i));
         //cashflow.setId(stockSymbol + "-" + date.getTime());
         cashflow.setDate(date);
        
         cashflow.setNetIncome(netIncome.get(i));
         cashflow.setDepreciation(depreciation.get(i));
         cashflow.setAdjustmentsToNetIncome(adjustmentsToNetIncome.get(i));
         cashflow.setChangesInAccountsReceivables(changesInAccountsReceivables.get(i));
         cashflow.setChangesInLiabilities(changesInLiabilities.get(i));
         cashflow.setChangesInInventories(changesInInventories.get(i));
         cashflow.setChangesInOthers(changesInOtherOperatingAcitivities.get(i));
         cashflow.setTotalCashflowFromOperatingActivities(totalCashflowFromOperatingActivities.get(i));
         cashflow.setCapitalExpenditures(captialExpenditures.get(i));
         cashflow.setInvestments(investments.get(i));
         cashflow.setOthersInvestingActivities(otherCashflowsFromInvestmentActivities.get(i));
         cashflow.setTotalCashflowFromInvestmentActivities(totalCashflowFromInvestmentActivities.get(i));
         cashflow.setDividendPaid(dividendsPaid.get(i));
         cashflow.setSalePurchaseOfStock(salePurchaseOfStock.get(i));
         cashflow.setNetBorrowing(netBorrowing.get(i));
         cashflow.setOtherFinancingActities(otherCashFlowsFromFinancingActivities.get(i));
         cashflow.setTotalCashflowsFromFinancingActivities(totalCashflowsFromFinancingActivities.get(i));
         cashflow.setEffectOfExchangeRate(effectOfExchangeRateChanges.get(i));
         cashflow.setChangeInCashAndCashEquivalents(changeInCashAndCashEquivalents.get(i));        
         cashflows.add(cashflow);
      }
      return cashflows;
   }
   
   public float getFloat(String value)
   {
      if (value != null && value.length() > 0)
      {
         try
         {
            if (value.trim().equals("N/A"))
            {
               return 0.0f;
            }
            if (value.trim().startsWith("("))
            {
               value = "-" + value.substring(1, value.length() - 2);
            }
            if (!"-".equals(value))
            {
               return numberFormat.parse(value).floatValue();
            }
         }
         catch (ParseException e)
         {
            //e.printStackTrace();
         }
      }
      return 0.0f;
   }
   
   public Date getDate(String format, String value)
   {
      if (value != null && value.length() > 0)
      {
         try
         {
            DateFormat dateFormat = new SimpleDateFormat(format);
            return dateFormat.parse(value);
         }
         catch (ParseException e)
         {
            
         }
      }
      return null;
   }
   
   public Date getDate(String value)
   {
      if (value != null && value.length() > 0)
      {
         try
         {
            return dateFormat.parse(value);
         }
         catch (ParseException e)
         {
           // e.printStackTrace();
         }
      }
      return null;
   }

   public long getLongValue(String value)
   {
      if (value != null && value.length() > 0)
      {

         try
         {
            return numberFormat.parse(value).longValue();
         }
         catch (ParseException e)
         {
            // TODO Auto-generated catch block
            // e.printStackTrace();
         }
      }
      return 0L;
   }
   
   public List<Float> getFloats(Map<String, List<String>> mapValue, String keyLike)
   {
      List<Float> values = new ArrayList<Float>();
      for(String stringValue : getValues(mapValue, keyLike))
      {
         values.add(this.getFloat(stringValue));
      }
      return values;
   }
   
   public List<String> getValues(Map<String, List<String>> mapValue, String keyLike)
   {
      if (keyLike == null || keyLike.length() == 0)
      {
         return Collections.emptyList();
      }
      for (String key: mapValue.keySet())
      {
         if (key.equals(keyLike))
         {
            return mapValue.get(key);
         }
         if (key.contains(keyLike))
         {
            return mapValue.get(key);
         }
         if (key.toLowerCase().contains(keyLike.toLowerCase()))
         {
            return mapValue.get(key);
         }
      }
      return Collections.emptyList();
   }

   public String getValue(Map<String, String> mapValue, String keyLike)
   {
      if (keyLike == null || keyLike.length() == 0)
      {
         return null;
      }
      for (String key: mapValue.keySet())
      {
         if (key.equals(keyLike))
         {
            return mapValue.get(key);
         }
         if (key.contains(keyLike))
         {
            return mapValue.get(key);
         }
         if (key.toLowerCase().contains(keyLike.toLowerCase()))
         {
            return mapValue.get(key);
         }
      }
      return null;
   }
   
   public void updateSummary(Stock company, Map<String, String> map)
   {
      //System.err.println(map);
     // Next Earnings Date:=22-Oct-12
      company.setNextEaringDate(getDate(map, "dd-MMM-yy", "Next Earnings Date"));
     // float earningsGrouth = company.getEarningsGrowth();
   }
   
   public void updateProfile(Stock company, Map<String, String> map)
   {
      company.setDescription(map.get("summary"));
      company.setState(map.get("state"));
      company.setCountry(map.get("country"));
      company.setCity(map.get("city"));
      company.setPostalCode(map.get("zipCode"));
      company.setPhone(map.get("phone"));
      company.setWebsite(map.get("website"));
      company.setStreet1(map.get("address"));
      company.setStreet2(map.get("address1"));
      
      for (String key: map.keySet())
      {
         if (key.contains("Chief Exec. Officer"))
         {
            company.setCEO(map.get(key));
         }
      }
      company.setEmployees(getLongValue(map.get("numberOfEmployees")));
      //System.err.println(map);
   }

   public void updateStats(Stock company, Map<String, String> map)
   {
      company.setMarketCap(getLong(map, "Market Cap"));
      company.setEnterpriseValue(getFloat(map, "Enterprise Value"));
      company.setTrailingPE(getFloat(map, "Trailing P/E"));
      company.setForwardPE(getFloat(map, "Forward P/E"));
      
      company.setPEGRatio(getFloat(map, "PEG Ratio"));
      company.setPriceOverSales(getFloat(map, "Price/Sales"));
      company.setPriceOverBook(getFloat(map, "Price/Book"));
      company.setEnterpriseValueOverRevenue(getFloat(map, "Enterprise Value/Revenue"));
      company.setEnterpriseValueOverEDITDA(getFloat(map, "Enterprise Value/EBITDA"));
      
      company.setFiscalYear(getString(map, "Fiscal Year Ends"));
      company.setMostRecentQuarter(getDate(map, "Most Recent Quarter"));
   
      company.setProfitMargin(getFloat(map, "Profit Margin"));   
      company.setOpratingMargin(getFloat(map, "Operating Margin"));   
      company.setReturnOnAssets(getFloat(map, "Return on Assets"));   
      company.setReturnOnEquity(getFloat(map, "Return on Equity"));   
      company.setRevenue(getLong(map, "Revenue"));   
      
      company.setRevenuePerShare(getFloat(map, "Revenue Per Share"));
      company.setRevenueGrowth(getFloat(map, "Qtrly Revenue Growth"));
      company.setGrossProfit(getFloat(map, "Gross Profit"));
      
      company.setEbitda(getFloat(map, "EBITDA "));
      
      company.setNetIncomeForCommon(getFloat(map, "Net Income Avl to Common"));
      company.setDilutedEPS(getFloat(map, "Diluted EPS"));
      company.setEarningsGrowth(getFloat(map, "Qtrly Earnings Growth"));

      company.setTotalCash(getFloat(map, "forward p/e"));
      company.setTotalCashPerShare(getFloat(map, "forward p/e"));

      company.setTotalDebt(getFloat(map, "forward p/e"));
      company.setDebtOverEquity(getFloat(map, "Total Debt/Equity"));
      
      company.setCurrentRatio(getFloat(map, "Current Ratio"));

      company.setBookValuePerShare(getFloat(map, "Book Value Per Share"));
      
      company.setOpratingCashflow(getFloat(map, "Operating Cash Flow"));
      company.setLeveredFreeCashflow(getFloat(map, "Levered Free Cash Flow"));
      
      company.setBeta(getFloat(map, "Beta"));
      company.setChangeIn52Weeks(getFloat(map, "52-Week Change"));
      company.setHighIn52(getFloat(map, "52-Week High"));
      company.setLowIn52(getFloat(map, "52-Week Low"));
      company.setMovingAverageIn50(getFloat(map, "50-Day Moving Average"));
      company.setMovingAverageIn200(getFloat(map, "200-Day Moving Average"));
      company.setAverageVolumeIn3Months(getFloat(map, "Avg Vol (3 month)"));
      company.setAverageVolumeIn10Days(getFloat(map, "Avg Vol (10 day)"));
      company.setSharesOutstanding(getFloat(map, "Shares Outstanding"));
      company.setSharesFloat(getFloat(map, "Float"));
      company.setSharesShort(getFloat(map, "Shares Short (as of"));
      
      company.setShortRatio(getFloat(map, "forward p/e"));
      company.setShortRatioOnFloat(getFloat(map, "forward p/e"));
      
      company.setDividend(getFloat(map, "Forward Annual Dividend Rate"));
      company.setDividendYield(getFloat(map, "Forward Annual Dividend Yield"));
      company.setPayoutRatio(getFloat(map, "Payout Ratio"));
      company.setDividendDate(getDate(map, "Dividend Date"));
      company.setExDividendDate(getDate(map, "Ex-Dividend Date"));
      company.setLastSplitFactor(getFloat(map, "Last Split Factor"));
      company.setLastSplitDate(getDate(map, "Last Split Date"));
   }
   
   private Date getDate(Map<String, String> map, String format, String keyLike)
   {
      String value = this.getValue(map, keyLike);
      if (value != null)
      {
         return this.getDate(format, value);
      }
      return new Date();
   }
   private Date getDate(Map<String, String> map, String keyLike)
   {
      String value = this.getValue(map, keyLike);
      if (value != null)
      {
         return this.getDate(value);
      }
      return new Date();
   }
   
   private String getString(Map<String, String> map, String keyLike)
   {
      return getValue(map, keyLike);
   }
   
   private float getFloat(Map<String, String> map, String keyLike)
   {
      String value = this.getValue(map, keyLike);
      if (value != null)
      {
         if (value.endsWith("M"))
         {
            return getFloat(value.substring(0, value.length() - 1)) * 1000000f;
         }
         else if (value.endsWith("%"))
         {
            return getFloat(value.substring(0, value.length() - 1));
         }
         else if (value.endsWith("B"))
         {
            return getFloat(value.substring(0, value.length() - 1)) * 10000000000f;
         }
         else
         {
            return getFloat(value);
         }
      }
      return 0L;
   }
   
   private long getLong(Map<String, String> map, String keyLike)
   {
      String value = this.getValue(map, keyLike);
      if (value != null)
      {
         float fValue=0f;
         if (value.endsWith("M"))
         {
            fValue = getFloat(value.substring(0, value.length() - 1)) * 1000000f;
         }
         else if (value.endsWith("B"))
         {
            fValue = getFloat(value.substring(0, value.length() - 1)) * 1000000000f;
         }
         else
         {
            fValue = getFloat(value.substring(0, value.length() - 1));
         }
         return new BigDecimal(fValue).longValue();
      }
      return 0L;
   }


}
