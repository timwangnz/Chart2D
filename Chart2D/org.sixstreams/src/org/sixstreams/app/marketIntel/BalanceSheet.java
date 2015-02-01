package org.sixstreams.app.marketIntel;


public class BalanceSheet extends StockCommon
{
   private float currentAssets;
   private float cash;
   private float shortTermInvestments;
   private float netReceivables;
   private float inventory;
   private float otherCurrentAssets;
   private float totalCurrentAssets;
   
   private float longTermInvestments;
   private float propertyPlantAndEquipment;
   private float goodWill;
   private float intangibleAssets;
   private float amortization;
   private float otherAssets;
   private float deferredLongTermAssetCharges;

   private float totalAssets;
   //liabilities
   private float accountsPayable;
   private float shortTermDebt;
   private float otherCurrentLiabilities;
   private float totalCurrentLiabilities;
   
   private float longTermDebt;
   private float otherLiabilities;
   private float deferredLongTermLiabilityCharges;
   private float minorityInterest;
   private float negativeGoodwill;
   private float totalLiabilities;
   //Equity
   private float miscStocksOptionsWarrants;
   private float redeemablePreferredStock;
   private float preferredStock;
   private float commonStock;
   private float retainedEarnings;
   private float treasureStock;
   private float capitalSurplus;
   private float otherStockholderEquity;
   private float totalStockholderEquity;
   
   private float netTangibleAssets;

   public void setCurrentAssets(float currentAssets)
   {
      this.currentAssets = currentAssets;
   }

   public float getCurrentAssets()
   {
      return currentAssets;
   }

   public void setCash(float cash)
   {
      this.cash = cash;
   }

   public float getCash()
   {
      return cash;
   }

   public void setShortTermInvestments(float shortTermInvestments)
   {
      this.shortTermInvestments = shortTermInvestments;
   }

   public float getShortTermInvestments()
   {
      return shortTermInvestments;
   }

   public void setNetReceivables(float netReceivables)
   {
      this.netReceivables = netReceivables;
   }

   public float getNetReceivables()
   {
      return netReceivables;
   }

   public void setInventory(float inventory)
   {
      this.inventory = inventory;
   }

   public float getInventory()
   {
      return inventory;
   }

   public void setOtherCurrentAssets(float otherCurrentAssets)
   {
      this.otherCurrentAssets = otherCurrentAssets;
   }

   public float getOtherCurrentAssets()
   {
      return otherCurrentAssets;
   }

   public void setTotalAssets(float totalAssets)
   {
      this.totalAssets = totalAssets;
   }

   public float getTotalAssets()
   {
      return totalAssets;
   }

   public void setLongTermInvestments(float longTermInvestments)
   {
      this.longTermInvestments = longTermInvestments;
   }

   public float getLongTermInvestments()
   {
      return longTermInvestments;
   }

   public void setPropertyPlantAndEquipment(float propertyPlantAndEquipment)
   {
      this.propertyPlantAndEquipment = propertyPlantAndEquipment;
   }

   public float getPropertyPlantAndEquipment()
   {
      return propertyPlantAndEquipment;
   }

   public void setGoodWill(float goodWill)
   {
      this.goodWill = goodWill;
   }

   public float getGoodWill()
   {
      return goodWill;
   }

   public void setIntangibleAssets(float intangibleAssets)
   {
      this.intangibleAssets = intangibleAssets;
   }

   public float getIntangibleAssets()
   {
      return intangibleAssets;
   }

   public void setAmortization(float amortization)
   {
      this.amortization = amortization;
   }

   public float getAmortization()
   {
      return amortization;
   }

   public void setOtherAssets(float otherAssets)
   {
      this.otherAssets = otherAssets;
   }

   public float getOtherAssets()
   {
      return otherAssets;
   }

   public void setDeferredLongTermAssetCharges(float deferredLongTermAssetCharges)
   {
      this.deferredLongTermAssetCharges = deferredLongTermAssetCharges;
   }

   public float getDeferredLongTermAssetCharges()
   {
      return deferredLongTermAssetCharges;
   }

   public void setTotalCurrentLiabilities(float currentLiabilities)
   {
      this.totalCurrentLiabilities = currentLiabilities;
   }

   public float getTotalCurrentLiabilities()
   {
      return totalCurrentLiabilities;
   }

   public void setAccountsPayable(float accountsPayable)
   {
      this.accountsPayable = accountsPayable;
   }

   public float getAccountsPayable()
   {
      return accountsPayable;
   }

   public void setShortTermDebt(float shortTermDebt)
   {
      this.shortTermDebt = shortTermDebt;
   }

   public float getShortTermDebt()
   {
      return shortTermDebt;
   }

   public void setOtherCurrentLiabilities(float otherCurrentDebt)
   {
      this.otherCurrentLiabilities = otherCurrentDebt;
   }

   public float getOtherCurrentLiabilities()
   {
      return otherCurrentLiabilities;
   }

   public void setLongTermDebt(float longTermDebt)
   {
      this.longTermDebt = longTermDebt;
   }

   public float getLongTermDebt()
   {
      return longTermDebt;
   }

   public void setOtherLiabilities(float otherLiabilities)
   {
      this.otherLiabilities = otherLiabilities;
   }

   public float getOtherLiabilities()
   {
      return otherLiabilities;
   }

   public void setDeferredLongTermLiabilityCharges(float deferredLongTermLiabilityCharges)
   {
      this.deferredLongTermLiabilityCharges = deferredLongTermLiabilityCharges;
   }

   public float getDeferredLongTermLiabilityCharges()
   {
      return deferredLongTermLiabilityCharges;
   }

   public void setMinorityInterest(float minorityInterest)
   {
      this.minorityInterest = minorityInterest;
   }

   public float getMinorityInterest()
   {
      return minorityInterest;
   }

   public void setNegativeGoodwill(float negativeGoodwill)
   {
      this.negativeGoodwill = negativeGoodwill;
   }

   public float getNegativeGoodwill()
   {
      return negativeGoodwill;
   }

   public void setTotalStockholderEquity(float totalStockholderEquity)
   {
      this.totalStockholderEquity = totalStockholderEquity;
   }

   public float getTotalStockholderEquity()
   {
      return totalStockholderEquity;
   }

   public void setMiscStocksOptionsWarrants(float stocksOptionsWarrants)
   {
      this.miscStocksOptionsWarrants = stocksOptionsWarrants;
   }

   public float getMiscStocksOptionsWarrants()
   {
      return miscStocksOptionsWarrants;
   }

   public void setRedeemablePreferredStock(float redeemablePreferredStock)
   {
      this.redeemablePreferredStock = redeemablePreferredStock;
   }

   public float getRedeemablePreferredStock()
   {
      return redeemablePreferredStock;
   }

   public void setPreferredStock(float preferredStock)
   {
      this.preferredStock = preferredStock;
   }

   public float getPreferredStock()
   {
      return preferredStock;
   }

   public void setCommonStock(float commonStock)
   {
      this.commonStock = commonStock;
   }

   public float getCommonStock()
   {
      return commonStock;
   }

   public void setRetainedEarnings(float retainedEarnings)
   {
      this.retainedEarnings = retainedEarnings;
   }

   public float getRetainedEarnings()
   {
      return retainedEarnings;
   }

   public void setTreasureStock(float treasureStock)
   {
      this.treasureStock = treasureStock;
   }

   public float getTreasureStock()
   {
      return treasureStock;
   }

   public void setCapitalSurplus(float capitalSurplus)
   {
      this.capitalSurplus = capitalSurplus;
   }

   public float getCapitalSurplus()
   {
      return capitalSurplus;
   }

   public void setOtherStockholderEquity(float otherStockholderEquity)
   {
      this.otherStockholderEquity = otherStockholderEquity;
   }

   public float getOtherStockholderEquity()
   {
      return otherStockholderEquity;
   }

   public void setNetTangibleAssets(float netTangibleAssets)
   {
      this.netTangibleAssets = netTangibleAssets;
   }

   public float getNetTangibleAssets()
   {
      return netTangibleAssets;
   }

   public void setTotalCurrentAssets(float totalCurrentAssets)
   {
      this.totalCurrentAssets = totalCurrentAssets;
   }

   public float getTotalCurrentAssets()
   {
      return totalCurrentAssets;
   }

   public void setTotalLiabilities(float totalLiabilities)
   {
      this.totalLiabilities = totalLiabilities;
   }

   public float getTotalLiabilities()
   {
      return totalLiabilities;
   }
}
