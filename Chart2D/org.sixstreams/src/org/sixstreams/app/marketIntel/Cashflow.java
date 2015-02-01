package org.sixstreams.app.marketIntel;

import java.util.Date;

public class Cashflow extends StockCommon
{
   private String stockSymbol;
   private float netIncome;
   private Date date;
   private float depreciation;
   private float adjustmentsToNetIncome;
   private float changesInAccountsReceivables;
   private float changesInLiabilities;
   private float changesInInventories;
   private float changesInOthers;
   
   private float capitalExpenditures;
   private float investments;
   private float othersInvestingActivities;
   
   private float dividendPaid;
   private float salePurchaseOfStock;
   private float netBorrowing;
   private float otherFinancingActities;
   
   private float effectOfExchangeRate;

   private float totalCashflowFromOperatingActivities;
   private float totalCashflowFromInvestmentActivities;
   private float changeInCashAndCashEquivalents;
   private float totalCashflowsFromFinancingActivities;
   
   public void setStockSymbol(String stockSymbol)
   {
      this.stockSymbol = stockSymbol;
   }

   public String getStockSymbol()
   {
      return stockSymbol;
   }

   public void setNetIncome(float netIncome)
   {
      this.netIncome = netIncome;
   }

   public float getNetIncome()
   {
      return netIncome;
   }

   public void setDate(Date date)
   {
      this.date = date;
   }

   public Date getDate()
   {
      return date;
   }

   public void setDepreciation(float depreciation)
   {
      this.depreciation = depreciation;
   }

   public float getDepreciation()
   {
      return depreciation;
   }

   public void setAdjustmentsToNetIncome(float adjustmentsToNetIncome)
   {
      this.adjustmentsToNetIncome = adjustmentsToNetIncome;
   }

   public float getAdjustmentsToNetIncome()
   {
      return adjustmentsToNetIncome;
   }

   public void setChangesInAccountsReceivables(float changesInAccountsReceivables)
   {
      this.changesInAccountsReceivables = changesInAccountsReceivables;
   }

   public float getChangesInAccountsReceivables()
   {
      return changesInAccountsReceivables;
   }

   public void setChangesInLiabilities(float changesInLiabilities)
   {
      this.changesInLiabilities = changesInLiabilities;
   }

   public float getChangesInLiabilities()
   {
      return changesInLiabilities;
   }

   public void setChangesInInventories(float changesInInventories)
   {
      this.changesInInventories = changesInInventories;
   }

   public float getChangesInInventories()
   {
      return changesInInventories;
   }

   public void setChangesInOthers(float changesInOthers)
   {
      this.changesInOthers = changesInOthers;
   }

   public float getChangesInOthers()
   {
      return changesInOthers;
   }

   public void setCapitalExpenditures(float capitalExpenditures)
   {
      this.capitalExpenditures = capitalExpenditures;
   }

   public float getCapitalExpenditures()
   {
      return capitalExpenditures;
   }

   public void setInvestments(float investments)
   {
      this.investments = investments;
   }

   public float getInvestments()
   {
      return investments;
   }

   public void setOthersInvestingActivities(float othersInvestingActivities)
   {
      this.othersInvestingActivities = othersInvestingActivities;
   }

   public float getOthersInvestingActivities()
   {
      return othersInvestingActivities;
   }

   public void setDividendPaid(float dividendPaid)
   {
      this.dividendPaid = dividendPaid;
   }

   public float getDividendPaid()
   {
      return dividendPaid;
   }

   public void setSalePurchaseOfStock(float salePurchaseOfStock)
   {
      this.salePurchaseOfStock = salePurchaseOfStock;
   }

   public float getSalePurchaseOfStock()
   {
      return salePurchaseOfStock;
   }

   public void setNetBorrowing(float netBorrowing)
   {
      this.netBorrowing = netBorrowing;
   }

   public float getNetBorrowing()
   {
      return netBorrowing;
   }

   public void setOtherFinancingActities(float otherFinancingActities)
   {
      this.otherFinancingActities = otherFinancingActities;
   }

   public float getOtherFinancingActities()
   {
      return otherFinancingActities;
   }

   public void setEffectOfExchangeRate(float effectOfExchangeRate)
   {
      this.effectOfExchangeRate = effectOfExchangeRate;
   }

   public float getEffectOfExchangeRate()
   {
      return effectOfExchangeRate;
   }

   public void setTotalCashflowFromOperatingActivities(float totalCashflowFromOperatingActivities)
   {
      this.totalCashflowFromOperatingActivities = totalCashflowFromOperatingActivities;
   }

   public float getTotalCashflowFromOperatingActivities()
   {
      return totalCashflowFromOperatingActivities;
   }

   public void setTotalCashflowFromInvestmentActivities(float totalCashflowFromInvestmentActivities)
   {
      this.totalCashflowFromInvestmentActivities = totalCashflowFromInvestmentActivities;
   }

   public float getTotalCashflowFromInvestmentActivities()
   {
      return totalCashflowFromInvestmentActivities;
   }

   public void setChangeInCashAndCashEquivalents(float changeInCashAndCashEquivalents)
   {
      this.changeInCashAndCashEquivalents = changeInCashAndCashEquivalents;
   }

   public float getChangeInCashAndCashEquivalents()
   {
      return changeInCashAndCashEquivalents;
   }


   public void setTotalCashflowsFromFinancingActivities(float totalCashflowsFromFinancingActivities)
   {
      this.totalCashflowsFromFinancingActivities = totalCashflowsFromFinancingActivities;
   }

   public float getTotalCashflowsFromFinancingActivities()
   {
      return totalCashflowsFromFinancingActivities;
   }
  
}
