//
//  ChartDimension.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/6/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class StringDimension: ChartDimension {
    var dimensionValues = [String]()
    var selectedValues = [String]()
    
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
            if let value = element[self.fieldName]  as? String
            {
                if (!contains(dimensionValues, value))
                {
                    dimensionValues.append(value);
                    if (i++ < 200)
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
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
        }
        self.selectedValues.sort() {
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
        }
    }
    
}
