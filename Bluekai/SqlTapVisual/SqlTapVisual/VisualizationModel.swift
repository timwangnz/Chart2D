//
//  VisualizationModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/6/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import Foundation
import Chart2D

class VisualizationModel: NSObject, BkDraggableDelegate, Graph2DDataSource {
    
    let data = BKRestData()
    let cacheManager : BKCacheManager =   BKCacheManager()
    
    var cacheTTL : Int = -1
    
    var chartRows : NSMutableArray = []
    var chartColumns : NSMutableArray = []
    
    var objects : NSMutableArray = []
    
    var chartObjects : NSMutableArray = []
    
    var valueFields : NSMutableArray = []
    
    var counting : Bool = false;
    
    var dimensions : NSMutableArray = []
    var measures : NSMutableArray = []
    
    var tableName : NSString? {
        didSet {
            chartColumns.removeAllObjects();
            chartRows.removeAllObjects();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.table.changed", object: nil)
        }
    }
    
    func swap(from: NSIndexPath, to: NSIndexPath) {
        //
    }
    
    func getSql() ->String
    {
        return "select count(*) from \(tableName!)"
    }
    
    func invalidateCache () -> Void
    {
        cacheManager.invalidateCache(self.getSql())
    }
    
    func checkCache () -> Bool
    {
        if let cached: AnyObject = cacheManager.getCache(self.getSql(), timeToLive: cacheTTL)
        {
            let dataReceived : NSDictionary = cached as! NSDictionary;
            let pts: NSArray = dataReceived["data"] as! NSArray
            objects.removeAllObjects()
            objects.arrayByAddingObjectsFromArray(pts as [AnyObject])
            return true;
        }
        return false;
    }
    
    func reload(callback: (data:NSDictionary!, error: NSError!) -> Void) -> Void
    {
        objects = NSMutableArray();
        if !self.checkCache()
        {
            data.sql = self.getSql()
            data.get (){ (response: NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                let jsonDict:NSDictionary = BKRestData.parseJSON(data)
                
                if let data : AnyObject? = jsonDict.objectForKey("data")
                {
                    self.objects.removeAllObjects()
                    self.objects.addObjectsFromArray(data as! [AnyObject])
                    NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.data.loaded", object: nil)
                }
                else if let status: AnyObject = jsonDict.objectForKey("status")
                {
                    println("encounted an error \(jsonDict)")
                    NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.data.error", object: jsonDict)
                }
                callback(data:jsonDict, error:error)
            }
        }
    }
    
    func deleteRowAt(index:Int)
    {
        let row: AnyObject = chartRows.objectAtIndex(index);
        if (row as! NSDictionary)["COLUMN_NAME"] as! String == "COUNTS"
        {
            self.counting = false
        }
        chartRows.removeObject(row)
         updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: chartRows)
    }
    
    func deleteColumnAt(index:Int)
    {
        chartColumns.removeObjectAtIndex(index)
         updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: chartColumns)
    }
    
    func addRow(row : AnyObject)
    {
        if (!chartRows.containsObject(row))
        {
            if(self.counting)
            {
                return;
            }
            
            if (row as! NSDictionary)["COLUMN_NAME"] as! String == "COUNTS"
            {
                self.counting = true
            }
            chartRows.addObject(row)
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: chartRows)
        }
    }
    
    func addColumn(column:AnyObject)
    {
        if (!chartColumns.containsObject(column))
        {
            chartColumns.addObject(column)
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: chartColumns)
        }
    }
    
    func numberOfValues() -> Int
    {
        return chartObjects.count
    }

    func totalGroupBy(rowName :String)
    {
        
        for colunm in chartColumns
        {
            
        }
        
    }
    
    func totalGroupBy(rowName :String, colName:String)
    {
        var groupBySum = Dictionary<String, Double>()
        for var i = 0; i < Int(count!); i++
        {
            let object : NSDictionary = objects.objectAtIndex(i) as! NSDictionary
            let dimension: AnyObject? = object[colName];
            
            println("\(dimension!)");
            
            let groupBy : String = "\(dimension!)"
            
            var sum = groupBySum[groupBy]
            
            if (sum == nil)
            {
                sum = 0
            }
            
            let measure: AnyObject? = object[rowName];
            sum = sum! + (measure as! Double)
            groupBySum[groupBy] = sum
            
        }
        
        for (kind, number) in groupBySum {
            chartObjects.addObject(["Marker":kind, rowName: number])
        }

    }
    
    func sumTotal(rowName :String)
    {
        var sum : Double = 0.0
        for var i = 0; i < Int(count!); i++
        {
            let object: NSDictionary = objects.objectAtIndex(i) as! NSDictionary
            let measure: AnyObject? = object[rowName];
            sum = sum + (measure as! Double)
        }
        chartObjects.addObject(["Marker":"Total Sales", rowName: sum]);
    }
    
    func updateModel()
    {
        chartObjects.removeAllObjects()
        if (chartRows.count == 0)
        {
            return;
        }
        
        let  row : NSDictionary = chartRows[0] as! NSDictionary
        let rowName = row["COLUMN_NAME"] as! String
        
        if (chartColumns.count == 0)
        {
            sumTotal(rowName);
        }
        else
        {
            let column : NSDictionary = chartColumns[0] as! NSDictionary
            let colName = column["COLUMN_NAME"] as! String
            totalGroupBy(rowName, colName: colName)
        }
    }
    

    func numberOfItems(graph2Dview: Graph2DView!, forSeries graph: Int) -> Int {
        return self.chartObjects.count
    }
    
    func numberOfSeries(graph2Dview: Graph2DView!) -> Int {
        return 1
    }
    
    func graph2DView(graph2DView: Graph2DView!, yLabelAt y: Double) -> String! {
        return String(format: "%.0f", y)//"\(y)"
    }

    func graph2DView(graph2DView: Graph2DView!, xLabelAt x: Int) -> String! {
        if self.chartObjects.count == 0
        {
            return ""
        }
        let object: AnyObject = chartObjects.objectAtIndex(x)
        let row : NSDictionary = object as! NSDictionary
        let xlabel: AnyObject = row.objectForKey("Marker")!
        return "\(xlabel)"
    }
    
    func graph2DView(graph2DView: Graph2DView!, valueAtIndex item: Int, forSeries series: Int) -> NSNumber! {
        let object: AnyObject = chartObjects.objectAtIndex(item)
        let row : NSDictionary = object as! NSDictionary
        
       // let fieldName = self.valueFields[series] as! String
        
        let  column : NSDictionary = chartRows[0] as! NSDictionary
        let fieldName = column["COLUMN_NAME"] as! String
        
        let value: AnyObject = row[fieldName]!
        
        if value.isKindOfClass(NSNumber)
        {
            return value as! NSNumber
        }
        else
        {
            let nValue = (value as! NSString).floatValue
            return nValue
        }
    }
    
    
    //testing data
   
    var  count:Double? = 120
    var waves:Double? = 2.0
    var offset:Double? = 1
    
    func setupData()
    {
        objects = NSMutableArray()
        valueFields = ["Sales", "Profit"];
        
        for var i = 0; i < Int(count!); i++
        {
            var k: Int = random() % 10;
            var fRand:Double = 100*Double(k);
            var value1:Double = Double(0.4) * sin(waves! * Double(i) * (M_PI/count!) * sin(offset!)) + fRand;
            var value2 =  4.0 + Double(1.5)  * cos(waves! * Double(i) * M_PI/count! + offset!) + fRand*2;
            var myObject = NSDate()
            let futureDate = myObject.dateByAddingTimeInterval(3600*24*Double(i))
            
            objects.addObject(
                [
                    "Sales" : value1,
                    "Marker": i,
                    "Date": futureDate,
                    "Product": "Product \(i%12)",
                    "Region": "Region \(i%4)",
                    "Profit": value2
                ]
            )
        }
        dimensions = NSMutableArray()
        dimensions.addObject(["COLUMN_NAME":"Date", "DATA_TYPE":"VARCHAR2"])
        dimensions.addObject(["COLUMN_NAME":"Product", "DATA_TYPE":"VARCHAR2"])
        dimensions.addObject(["COLUMN_NAME":"Region", "DATA_TYPE":"VARCHAR2"])
        measures = NSMutableArray()
        measures.addObject(["COLUMN_NAME":"Sales", "DATA_TYPE":"NUMBER"])
        measures.addObject(["COLUMN_NAME":"Profit", "DATA_TYPE":"NUMBER"])
        measures.addObject(["COLUMN_NAME":"Marker", "DATA_TYPE":"NUMBER"])
    }
}
