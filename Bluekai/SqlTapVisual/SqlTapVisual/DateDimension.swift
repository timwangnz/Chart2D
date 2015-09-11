//
//  DateDimension.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

enum DateDimensionRange : Int {
    case Day
    case Year
    case Month
    case Week
}

class DateDimension: Dimension {
    
    var range : DateDimensionRange = DateDimensionRange.Year
    
    var buckets = [DateDimensionValue]()
    
    func dateRangeForMonth(date:NSDate) -> DateDimensionValue
    {
        let calendar = NSCalendar.currentCalendar()
        let firstDayOfMonth  = calendar.dateWithEra(1, year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: calendar.component(.CalendarUnitMonth, fromDate: date), day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!   // "Jan 1, 2015, 12:00 AM"
        let lastDayOfMonth  = calendar.dateWithEra(1, year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: calendar.component(.CalendarUnitMonth, fromDate: date), day: 31, hour: 0, minute: 0, second: 0, nanosecond: 0)!   // "Dec 31, 2015, 12:00 AM"
        return DateDimensionValue(dimension: self, fromValue: firstDayOfMonth, toValue: lastDayOfMonth)
    }
    
    func dateRangeForYear(date:NSDate) -> DateDimensionValue
    {
        let calendar = NSCalendar.currentCalendar()
        
        let firstDayOfTheYear  = calendar.dateWithEra(1, year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!   // "Jan 1, 2015, 12:00 AM"
        let lastDayOfTheYear  = calendar.dateWithEra(1, year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: 12, day: 31, hour: 0, minute: 0, second: 0, nanosecond: 0)!   // "Dec 31, 2015, 12:00 AM"
        
        return DateDimensionValue(dimension: self, fromValue: firstDayOfTheYear, toValue: lastDayOfTheYear)
    }
    
    func setRange(newRange :DateDimensionRange)
    {
        self.range = newRange
    }
    
    func dateRangeForDay(date:NSDate) -> DateDimensionValue
    {
        let calendar = NSCalendar.currentCalendar()
        
        let morning  = calendar.dateWithEra(1,
            year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: calendar.component(.CalendarUnitMonth, fromDate: date),
            day : calendar.component(.CalendarUnitDay, fromDate: date),
            hour: 0, minute: 0, second: 0, nanosecond: 0)!
        
        let night  =  calendar.dateWithEra(1,
            year: calendar.component(.CalendarUnitYear, fromDate: date),
            month: calendar.component(.CalendarUnitMonth, fromDate: date),
            day : calendar.component(.CalendarUnitDay, fromDate: date) + 1,
            hour: 0, minute: 0, second: 0, nanosecond: 0)!
        return DateDimensionValue(dimension: self, fromValue: morning, toValue: night)
    }
    
    func getDateDimensionValue(date: NSDate) -> DateDimensionValue
    {
        if (range == DateDimensionRange.Year)
        {
            return dateRangeForYear(date)
        }
        else if (range == DateDimensionRange.Month)
        {
            return dateRangeForMonth(date)
        }
        else
        {
            return dateRangeForDay(date)
        }
    }
    
    override func containsDimensionValue(testValue : AnyObject?) -> DimensionValue?
    {
        if (testValue == nil)
        {
            return nil
        }
        
        let date = testValue as! NSDate
        
        let dimValue = getDateDimensionValue(date)
        
        for dimensionValue in dimensionValues
        {
            if (dimensionValue.isEqual(dimValue))
            {
                return nil
            }
        }
        return dimValue
    }
}
