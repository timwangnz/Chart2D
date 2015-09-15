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

enum SortBy : Int {
    case Name
    case Value
}


class Dimension: ChartField {
    var sortBy : SortBy = SortBy.Name
    var dimensionValues = [DimensionValue]()
    var usedValues = [DimensionValue]()
    var blacklist = [DimensionValue]()
    var whitelist = [DimensionValue]()
    
    func makeNew()->Dimension
    {
        var newCopy = Dimension(fieldName: self.fieldName, dateType: self.dataType, type: self.type);
        return newCopy
    }
    
    func addToWhitelist(dimValue : DimensionValue)
    {
        if (contains(whitelist, dimValue))
        {
            return;
        }
        whitelist.append(dimValue)
    }
    
    func addToBlacklist(dimValue : DimensionValue)
    {
        if (contains(blacklist, dimValue))
        {
            return;
        }
        blacklist.append(dimValue)
    }

    func containsDimensionValue(testValue : AnyObject?) -> DimensionValue?
    {
        if (testValue == nil)
        {
            return nil
        }
        let dimValue = SingleDimensionValue(dimension: self, fromValue: testValue)
        if contains(dimensionValues, dimValue)
        {
            return nil
        }
        return dimValue
    }
    
    func checkAllowed(dimensionValue : DimensionValue) -> Bool
    {
        if (contains(self.blacklist, dimensionValue))
        {
            return false
        }
        
        let eq1 = (self.whitelist.count > 0) && !contains(self.whitelist, dimensionValue)
        
        if eq1
        {
            return false
        }
        
        return true;
    }
    
    func getDimensionValues() -> [DimensionValue]
    {
        var allowed = [DimensionValue]()
        for dimValue in usedValues
        {
            if (self.checkAllowed(dimValue))
            {
                allowed.append(dimValue);
            }
        }
        allowed.sort() {
            $0.compare($1) == NSComparisonResult.OrderedAscending
        }
        return allowed
    }

    //figure out distinct dimensional values
    func buildDimensionValuesFromData(candidates : NSMutableArray) -> [DimensionValue]
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
                if (i++ < 100)
                {
                    usedValues.append(value);
                }
            }
        }
       
        return usedValues
    }
}