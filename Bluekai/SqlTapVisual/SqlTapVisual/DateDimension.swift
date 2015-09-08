//
//  DateDimension.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class DateDimension: ChartDimension {
    var dimensionValues = [NSDate]()
    var selectedValues = [NSDate]()
    
    func containsDate(testValue : NSDate) -> Bool
    {
        for date in dimensionValues
        {
            if date == testValue
            {
                return true;
            }
        }
        return false;
        
    }
    
    class func toDate(stringValue :String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let date = dateFormatter.dateFromString(stringValue)
        return date!;
    }
    
    override func getDimensionValues(candidates:NSMutableArray) -> [AnyObject]
    {
        if (dimensionValues.count > 0)
        {
            return selectedValues;
        }
        
        //ticktock.TICK("\(fieldName)")
        var i = 0;
        
        selectedValues.removeAll(keepCapacity: false)
        
        for element in candidates
        {
            if let value = element[self.fieldName] as? NSDate
            {
                if containsDate(value) == false
                {
                    dimensionValues.append(value);
                    if (i++ < 20)
                    {
                        selectedValues.append(value);
                    }
                }
            }
        }
        sort()
        //println("number of values \(dimensionValues.count) for \(self.fieldName)")
        //ticktock.TOCK()
        return selectedValues
    }
    
    func sort()
    {
        self.dimensionValues.sort() {
             $0.compare($1) == NSComparisonResult.OrderedAscending
        }
        self.selectedValues.sort() {
             $0.compare($1) == NSComparisonResult.OrderedAscending
        }
    }

}
