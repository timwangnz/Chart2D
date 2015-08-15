//
//  StaticDataSource.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 8/15/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class StaticDataSource: NSObject {
    let data = RestfulDataSource()
    let cacheManager : CacheManager =   CacheManager()
    //testing data
    var objects : NSMutableArray = []
    var dimensions = [ChartField]()
    var measures = [ChartField]()
    var  count:Double? = 40
    var waves:Double? = 2.0
    var offset:Double? = 1
    
    var cacheTTL : Int = -1
    var valueFields : NSMutableArray = []
    
    func invalidateCache () -> Void
    {
        cacheManager.invalidateCache(self.getSql())
    }
    
    var tableName : NSString? {
        didSet {
            
        }
    }
    
    func getSql() ->String
    {
        return "select count(*) from \(tableName!)"
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
                let jsonDict:NSDictionary = RestfulDataSource.parseJSON(data)
                
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
    
    override init()
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
                    "Date": "\(futureDate)",
                    "Product": "Product \(i%12)",
                    "Region": "Region \(i%4)",
                    "Profit": value2
                ]
            )
        }
        
        dimensions.append(ChartField(fieldName: "Date", dateType: "Date", type: 0))
        dimensions.append(ChartField(fieldName: "Product", dateType: "String", type: 0))
        dimensions.append(ChartField(fieldName: "Region", dateType: "String", type: 0))
        
        measures.append(ChartField(fieldName: "Sales", dateType: "Number", type: 1))
        measures.append(ChartField(fieldName: "Profit", dateType: "Number", type: 1))
        measures.append(ChartField(fieldName: "Marker", dateType: "Number", type: 1))
    }
    
}
