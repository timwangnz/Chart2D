//
//  RangeDimensionValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

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
    
    func toWeekDay() -> Int
    {
        let myComponents = myCalendar.components(.Weekday, fromDate: self)
        return myComponents.weekday
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
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}


class DateDimensionValue: DimensionValue {
    override func isEqual(object: AnyObject?) -> Bool {
        if object is DateDimensionValue && fromValue != nil
        {
            let obj = object as! DateDimensionValue
            return self.fromValue!.isEqual(obj.fromValue!) //&& self.toValue!.isEqual(obj.toValue)
        }
        return false
    }
    
    //check if a measure should be counted
    override func test(testObject : AnyObject?) -> Bool
    {
        if !(testObject is NSDate)
        {
            return false
        }
        if fromValue is NSDate && toValue is NSDate
        {
            let testValue = testObject as? NSDate
            return testValue!.greaterThan(fromValue as! NSDate) && testValue!.lessThan(toValue as! NSDate)
        }
        else if (fromValue is Int) && (testObject is NSDate)
        {
            if (self.dimension as! DateDimension).range == .Week
            {
                let testValue = testObject as? NSDate
                let dayofweek = testValue!.toWeekDay()
                return (fromValue as! Int) == dayofweek
            }
        }
        return false
    }
}
