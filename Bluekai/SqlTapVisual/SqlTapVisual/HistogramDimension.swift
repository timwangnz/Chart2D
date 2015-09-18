//
//  HistogramDimension.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/14/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class HistogramDimension: Dimension {
    //split value into 10 buckets
    var buckets : Int = 10
    
    override func makeNew()->Dimension
    {
        let newCopy = HistogramDimension(fieldName: self.fieldName, dateType: self.dataType, type: self.type);
        newCopy.buckets = self.buckets;
        return newCopy
    }
    
    override func buildDimensionValuesFromData(aggregatedValue : AggregatedValue) -> [DimensionValue]
    {
        if buckets == 0
        {
            buckets = 10
        }
        
        if (dimensionValues.count > 0)
        {
            return usedValues;
        }
        
        usedValues.removeAll(keepCapacity: false)
        
        let step = Double(aggregatedValue.max - aggregatedValue.min)/Double(buckets)
        
        for var i = 0; i < buckets; i++
        {
            let dimValue = HistogramDimensionValue(dimension: self, fromValue: Double(aggregatedValue.min + Double(i)*step), toValue: Double(aggregatedValue.min + Double(i+1)*step))
            usedValues.append(dimValue)
            dimensionValues.append(dimValue)
        }
        return usedValues
    }
}
