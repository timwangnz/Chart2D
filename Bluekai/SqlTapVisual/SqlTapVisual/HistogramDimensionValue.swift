//
//  HistogramDimensionValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/14/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class HistogramDimensionValue: DimensionValue {
    override func isEqual(object: AnyObject?) -> Bool {
        if object is HistogramDimensionValue && fromValue != nil
        {
            let obj = object as! HistogramDimensionValue
            return self.fromValue!.isEqual(obj.fromValue!) && self.toValue!.isEqual(obj.toValue)
        }
        return false
    }
    
    //check if a measure should be counted
    override func test(testObject : AnyObject?) -> Bool
    {
        let lower = self.fromValue as! Double
        let upper = self.toValue as! Double
        let value = testObject as! Double
        return value > lower && value <= upper
    }

}
