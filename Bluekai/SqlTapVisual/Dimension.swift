//
//  ChartDimension.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
/**
    A chart dimension has a list of dimension values, each dimension value can group a list of measures to get a subtotal
    dimensionValue can have child dimensionValues, its like a tree branches
**/

class Dimension: ChartField {
    
    static var dataFormats = [String : NSDateFormatter]()
    
    class func getDateFormatter(dateformat : String) -> NSDateFormatter
    {
        if let formatter = dataFormats[dateformat]
        {
            return formatter
        }
        else
        {
            let newFormatter = NSDateFormatter()
            newFormatter.dateFormat = dateformat
            dataFormats.updateValue(newFormatter, forKey: dateformat)
            return newFormatter
        }
    }
    
    class func toDate(stringValue : String, format: String) -> NSDate
    {
        return getDateFormatter(format).dateFromString(stringValue)!
    }
    
    
    func formatObject(object : AnyObject?) -> String
    {
        if (object == nil)
        {
            return ""
        }
        
        if (object is NSDate)
        {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            //formatter.timeStyle = .ShortStyle
            return formatter.stringFromDate(object as! NSDate)
        }
        return "\(object!)"
    }
    
    
    var dimensionValues = [DimensionValue]()
    var usedValues = [DimensionValue]()
    
    func containsDimensionValue(testValue : AnyObject?) -> DimensionValue?
    {
        if (testValue == nil)
        {
            return nil
        }
        
        let dimValue = SingleDimensionValue(dimension: self, fromValue: testValue)
        for dimensionValue in dimensionValues
        {
            if (dimensionValue.isEqual(dimValue))
            {
                return nil
            }
        }
        return dimValue
    }
    
    //figure out distinct dimensional values
    func getDimensionValues(candidates : NSMutableArray) -> [DimensionValue]
    {
        if (dimensionValues.count > 0)
        {
            return usedValues;
        }
        
        var i = 0;
        usedValues.removeAll(keepCapacity: false)
        for element in candidates
        {
            let valueObject = element[self.fieldName]
            
            if let value = containsDimensionValue(valueObject)
            {
                dimensionValues.append(value);
                if (i++ < 20)
                {
                    usedValues.append(value);
                }
            }
            
        }
        return usedValues
    }
    
    func sort()
    {
        self.dimensionValues.sort() {
            $0.compare($1) == NSComparisonResult.OrderedAscending
        }
        self.usedValues.sort() {
            $0.compare($1) == NSComparisonResult.OrderedAscending
        }
    }
}
