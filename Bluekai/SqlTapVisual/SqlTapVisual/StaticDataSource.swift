//
//  StaticDataSource.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 8/15/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class StaticDataSource: NSObject {
    let cacheManager : CacheManager =   CacheManager()
    //testing data
    var objects : NSMutableArray = []
    var dimensions = [ChartDimension]()
    var measures = [ChartField]()
    
    var valueFields : NSMutableArray = []
    
    func loadData() -> Void
    {
        let filePath = NSBundle.mainBundle().pathForResource("salesSampleData",ofType:"json")
        var readError:NSError?
        
        if let jsonData = NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached, error:&readError) {
            var error: NSError?
            
            let jsonArray = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSArray
            
            objects.addObjectsFromArray(jsonArray! as [AnyObject])
            analyze()
            convert()
            
        }
    }
    
    func convert()->Void
    {
        ticktock.TICK("Test conversion")
        for object in objects
        {
            for (key, value) in object as! Dictionary<String, AnyObject>
            {
                if let textRange = key.rangeOfString("Date") {
                    let dateValue = DateDimension.toDate(value as! String)
                    object.setObject(dateValue, forKey: key)
                }
            }
        }
        ticktock.TOCK()
    }
    
    func analyze() -> Void
    {
        dimensions.removeAll(keepCapacity: false)
        measures.removeAll(keepCapacity: false)
        if let jsonResult = objects.objectAtIndex(0) as? Dictionary<String, AnyObject> {
            for (key, value) in jsonResult
            {
                if value is String
                {
                    if let textRange = key.rangeOfString("Date") {
                        dimensions.append(DateDimension(fieldName: key, dateType: "Date", type: 0))
                    }
                    else
                    {
                        dimensions.append(StringDimension(fieldName: key, dateType: "String", type: 0))
                    }
                }
                else
                if value is Int{
                    measures.append(ChartField(fieldName: key, dateType: "Number", type: 1))
                }
                else
                if value is Float{
                    measures.append(ChartField(fieldName: key, dateType: "Number", type: 1))
                }
            }
        }
    }
    
    override init()
    {
        super.init()
        loadData();
    }
    
}
