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
        return NSComparisonResult.OrderedSame
    }
    
    func customDescription() -> String {
        return dimension!.formatObject(self.fromValue!)
    }
    
    override var description: String {
        return customDescription()
    }
}
