//
//  ChartDimensionValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/19/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit


/**
an aggregated value should be a matrix

values list of value to be aggregated

root 
    total
    list of values
    product
            p1
                subtotal
                list of values (product = p1)
                date
                    d1
                        subtotal
                        list of values (product = p1, date = d1)
                    d2
                    d3
            p2
            p3
            p4
**/

class AggregatedValue: NSObject {
    
    
    var valueObjects : NSMutableArray = []
    var max : Double = -100000000000000.0
    var min : Double =  100000000000000.0
    var sum : Double = 0
    var average :Double = 0.0
    var count : Int = 0
    
    
    var hasSubDimensions : Bool = false
    
    var measure : Measure
    
    var dimension : Dimension?
    var dimensionValue : DimensionValue?
        {
        didSet {
            self.dimensionValue?.value = self;
        }
    }
    
    var children = [AggregatedValue]()
    
    var parent : AggregatedValue?

    var maxOfChildren : Double = -100000000000.0
    var minOfChildren : Double = 100000000000.0
    

    /**
    * Initialized root
    **/
    init(measure : Measure, values : NSMutableArray)
    {
        self.measure = measure
        self.dimension = nil
        //self.dimensionValue = nil
        self.parent = nil
        self.count = values.count
        self.valueObjects = values;
        sum = 0;
        if (self.measure.fieldName != "Number Of Records")
        {
            for valueObject in self.valueObjects
            {
                let value = valueObject[self.measure.fieldName] as! Double
                if (value >= max)
                {
                    max = value
                }
                if (value < min)
                {
                    min = value
                }
                
                sum = sum + value;
            }
            average = sum/Double(count);
        }
        else
        {
            sum = Double(self.count)
        }
    }
    
    func getValue()->Double
    {
        let valueType = measure.valueType
        
        if valueType == AggregatedValueType.Sum
        {
            return sum
        } else if valueType == AggregatedValueType.Average
        {
            return average
        }
        else if valueType == AggregatedValueType.Count
        {
            return Double(count)
        }
        else
        {
            return sum
        }
    }
    
    func sortChildren(order : NSComparisonResult) ->Void
    {
        if children.count < 2
        {
            return;
        }
        
        children.sortInPlace {
            $1.dimensionValue!.compare($0.dimensionValue!) == order
        }
    }
    
    func getDimensionValueAt(x : Int) -> String
    {
        let valueObject : NSDictionary = valueObjects[x] as! NSDictionary;
        return valueObject[self.dimension!.fieldName] as! String
    }
    
    func getPath() -> [String]
    {
        var path = [String]()
        for (child) in children
        {
            path.append("\(child.dimensionValue!)")
        }
        return path
    }
    
    func getDimensionSubset(dimensionName:String, dimensionValue : DimensionValue, candidates:NSMutableArray) -> NSMutableArray
    {
        let subset : NSMutableArray = []
        for element in candidates
        {
            let ele = element[dimensionName]
            if ele != nil
            {
                if dimensionValue.test(ele)
                {
                    subset.addObject(element);
                }
            }
        }
        return subset;
    }
    
    func getDimensionSubsets(dimensionName:String, dimensionValues : [DimensionValue], candidates:NSMutableArray) -> Dictionary<DimensionValue, NSMutableArray>
    {
        var subsets = Dictionary<DimensionValue, NSMutableArray>()
        ticktock.TICK("getDimensionSubsets \(dimensionName)")
        for element in candidates
        {
            let ele = element[dimensionName]
            
            for dimensionValue in dimensionValues
            {
                if dimensionValue.test(ele)
                {
                    let subset = subsets[dimensionValue]
                    
                    if (subset != nil)
                    {
                        subset!.addObject(element);
                        
                    }else
                    {
                        let newsubset = NSMutableArray()
                        newsubset.addObject(element);
                        subsets.updateValue(newsubset, forKey: dimensionValue)
                        
                    }
                }
            }
        }
        ticktock.TOCK()
        return subsets;
    }
    
    func buildValueModel(dimension : Dimension) -> [AggregatedValue]
    {
        var returnValue = [AggregatedValue]()
        ticktock.TICK("buildValueModel")
        dimension.buildDimensionValuesFromData(self)
        ticktock.TOCK()
        var i : Int = 0;
        
        let dimensionValues = dimension.getDimensionValues()
        
        let subsets = getDimensionSubsets(dimension.fieldName, dimensionValues: dimensionValues, candidates: valueObjects);
        ticktock.TOCK()
        
        for dimensionValue in dimensionValues
        {
            if let subset = subsets[dimensionValue]
            {
                let aggValue = AggregatedValue(measure: self.measure, values: subset)
                
                aggValue.dimension = dimension
                aggValue.dimensionValue = dimensionValue
                
                if (maxOfChildren < aggValue.getValue())
                {
                    maxOfChildren = aggValue.getValue()
                }
                
                if (minOfChildren > aggValue.getValue())
                {
                    minOfChildren = aggValue.getValue()
                }
                
                aggValue.parent = self
                returnValue.append(aggValue)
                i++;
            }
        }
        ticktock.TOCK()
        return returnValue
    }
    
    func getValuePath()->String
    {
        if (dimensionValue != nil)
        {
            if (self.parent == nil)
            {
                return "\(dimensionValue!)"
            }
            else
            {
                return "\(self.parent!.getValuePath()).\(dimensionValue!)"
            }
        }
        return ""
    }
    
    func buildValueModelTree(dimensions : [Dimension]) -> Void
    {
        if (dimensions.isEmpty)
        {
            return
        }
       
        var localDimensions = dimensions;
        self.dimension = localDimensions.first;
    
        children = buildValueModel(self.dimension!)
      
        self.sortChildren(NSComparisonResult.OrderedAscending)

        localDimensions.removeAtIndex(0)
        if (!localDimensions.isEmpty)
        {
            for (aggregatedValue) in children
            {
                aggregatedValue.parent = self;
                self.hasSubDimensions = true;
                aggregatedValue.buildValueModelTree(localDimensions)
            }
        }
        
    }
    
    func printTree()
    {
        if (self.dimensionValue != nil)
        {
            print("\(self.getValuePath()) \(self.getValue())");
        }
        
        for (value) in children
        {
            value.printTree()
        }
    }
}
