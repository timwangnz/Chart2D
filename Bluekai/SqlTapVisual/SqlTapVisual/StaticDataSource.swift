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
    
    var dimensions = [Dimension]()
    var measures = [Measure]()
    
    var valueFields : NSMutableArray = []
    
    func loadData() -> Void
    {
        
        let filePath = NSBundle.mainBundle().pathForResource("salesSampleData",ofType:"json")
        //ticktock.TICK("Process \(filePath)")
        
        let jsonData = try? NSData(contentsOfFile:filePath!, options:NSDataReadingOptions.DataReadingUncached)
        let jsonArray = try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
        objects.addObjectsFromArray(jsonArray! as! [AnyObject])
        analyze()
        convert()
        
        //ticktock.TOCK()
    }
    
    func convert()->Void
    {
        for object in objects
        {
            for (key, value) in object as! Dictionary<String, AnyObject>
            {
                let textRange = key.rangeOfString("Date")
                if textRange != nil {
                    let dateValue = Dimension.toDate(value as! String, format: "MM/dd/yy")
                    object.setObject(dateValue, forKey: key)
                }
            }
        }
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
                    let textRange = key.rangeOfString("Date")
                    if textRange != nil
                    {
                        dimensions.append(DateDimension(fieldName: key, dateType: "Date", type: 0))
                    }
                    else
                    {
                        dimensions.append(Dimension(fieldName: key, dateType: "String", type: 0))
                    }
                }
                else if value is Int{
                    measures.append(Measure(fieldName: key, dateType: "Int", type: 1))
                }
                else if value is Float{
                    measures.append(Measure(fieldName: key, dateType: "Float", type: 1))
                }
            }
        }
        measures.append(Measure(fieldName: "Number Of Records", dateType: "Int", type: 1))
    }
    
    override init()
    {
        super.init()
        loadData();
    }
    
}
