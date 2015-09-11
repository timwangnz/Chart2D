//
//  RangeDimensionValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

extension NSDate
{
    func greaterThan(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func lessThan(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func equalsTo(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame
        {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        var secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        var dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        var secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        var dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}


class DateDimensionValue: DimensionValue {
    
    override func isEqual(object: AnyObject?) -> Bool {
        if object is DateDimensionValue && fromValue != nil
        {
            let obj = object as! DateDimensionValue
            return self.fromValue!.isEqual(obj.fromValue) && self.toValue!.isEqual(obj.toValue)
        }
        return false
    }
    
    //check if a measure should be counted
    override func test(testObject : AnyObject?) -> Bool
    {
        if fromValue is NSDate && toValue is NSDate
        {
            let testValue = testObject as? NSDate
            return testValue!.greaterThan(fromValue as! NSDate) && testValue!.lessThan(toValue as! NSDate)
        }
        return false
    }
    
    override func compare(object : DimensionValue) -> NSComparisonResult
    {
        let objectToCompare = object as! DateDimensionValue
        
        if fromValue is NSDate
        {
            let testValue = objectToCompare.fromValue as? NSDate
            return testValue!.compare(self.fromValue as! NSDate)
        }
        else if self.fromValue is Int && self.toValue is Int
        {
            let testValue = objectToCompare.fromValue as? Int
            let fromValue = self.fromValue as! Int
            
            return testValue > fromValue ? NSComparisonResult.OrderedAscending : NSComparisonResult.OrderedDescending
            
        }else if self.fromValue is Double && self.toValue is Double{
            let testValue = objectToCompare.fromValue as? Double
            let fromValue = self.fromValue as! Double
            return testValue > fromValue ? NSComparisonResult.OrderedAscending : NSComparisonResult.OrderedDescending
        }
        else
        {
            return NSComparisonResult.OrderedSame
        }
    }
}
