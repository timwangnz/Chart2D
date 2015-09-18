//
//  Measure.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

enum AggregatedValueType : Int {
    case Sum
    case Average
    case Count
}

class Measure: ChartField {
    
    var valueType : AggregatedValueType = AggregatedValueType.Sum
    func makeNew()->Measure
    {
        let newCopy = Measure(fieldName: self.fieldName, dateType: self.dataType, type: self.type);
        newCopy.valueType = self.valueType
        
        return newCopy
    }
    
    func toDimension(buckets : Int) -> HistogramDimension
    {
        let dim = HistogramDimension(fieldName: self.fieldName, dateType: self.dataType, type: self.type)
        dim.buckets = buckets;
        return dim;
    }
}
