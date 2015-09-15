//
//  DimensionValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit


class DimensionValue: NSObject {

    var fromValue : AnyObject?
    var toValue : AnyObject?
    var dimension :Dimension?
    
    init(dimension : Dimension, fromValue: AnyObject?)
    {
        self.dimension = dimension
        self.fromValue = fromValue;
    }
    
    init(dimension : Dimension, fromValue: AnyObject?, toValue : AnyObject)
    {
        self.dimension = dimension
        self.fromValue = fromValue;
        self.toValue = toValue;
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        if object is DimensionValue
        {
            if fromValue != nil && toValue == nil
            {
                return self.fromValue!.isEqual((object as! DimensionValue).fromValue)
            }
        }
        return false
    }
    
    //check if a measure should be counted
    func test(testObject : AnyObject?) -> Bool
    {
        return self.fromValue!.isEqual(testObject!)
    }
    
    func compare(object : DimensionValue) -> NSComparisonResult
    {
        if dimension!.sortBy == SortBy.Name
        {
            return compareNames(object)
        }
        else
        {
            return compareValues(object)
        }
    }
    
    var value : AggregatedValue?
    
    func compareValues(object : DimensionValue) -> NSComparisonResult
    {
        let value1 = self.value
        let value2 = object.value
        if (value1 != nil && value2 != nil)
        {
            let v1 = value1!.getValue()
            let v2 = value2!.getValue()
            return v1 < v2 ? NSComparisonResult.OrderedAscending : NSComparisonResult.OrderedDescending
        }
        return NSComparisonResult.OrderedSame
    }
    
    func compareNames(object : DimensionValue) -> NSComparisonResult
    {
        if fromValue is NSDate
        {
            let testValue = object.fromValue as? NSDate
            return testValue!.compare(self.fromValue as! NSDate)
        }
        else if self.fromValue is Int && self.toValue is Int
        {
            let testValue = object.fromValue as? Int
            let fromValue = self.fromValue as! Int
            
            return testValue < fromValue ? NSComparisonResult.OrderedAscending : NSComparisonResult.OrderedDescending
            
        }else if self.fromValue is Double && self.toValue is Double{
            let testValue = object.fromValue as? Double
            let fromValue = self.fromValue as! Double
            return testValue < fromValue ? NSComparisonResult.OrderedAscending : NSComparisonResult.OrderedDescending
        }
        else if self.fromValue is String && object.fromValue is String {
            let testValue = object.fromValue as! String
            let fromValue = self.fromValue as! String
            return testValue.compare(fromValue)
        }
        else
        {
            return NSComparisonResult.OrderedSame
        }
    }
    
    func customDescription() -> String {
        return dimension!.formatObject(self.fromValue!)
    }
    
    override var description: String {
        return customDescription()
    }
}
