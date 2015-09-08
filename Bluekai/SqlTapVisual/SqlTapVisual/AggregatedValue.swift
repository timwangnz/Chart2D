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
    
    var subtotal : Double = 0
    var count : Int = 0
    
    var valueObjects : NSMutableArray = []
    var hasSubDimensions : Bool = false
    
    var measure : ChartField
    
    var dimension : ChartDimension?
    var dimensionValue : AnyObject?
    
    var children = [AggregatedValue]()
    
    var parent : AggregatedValue?
    var max : Double = -100000000000000.0;
    var min : Double =  100000000000000.0;
    
    /**
    * Initialized root
    **/
    init(measure : ChartField, values : NSMutableArray)
    {
        self.measure = measure
        
        self.dimension = nil
        self.dimensionValue = nil
        self.parent = nil
        self.count = values.count
        self.valueObjects = values;
        for valueObject in self.valueObjects
        {
            subtotal = subtotal + (valueObject[self.measure.fieldName] as! Double);
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
    
    func getDimensionSubset(dimensionName:String, dimensionValue : AnyObject, candidates:NSMutableArray) -> NSMutableArray
    {
        var subset : NSMutableArray = []
        for element in candidates
        {
            let ele = element[dimensionName]
            if ele != nil
            {
                if dimensionValue.isEqual(ele)
                {
                    subset.addObject(element);
                }
            }
        }
        return subset;
    }
        
    func buildValueModel(var dimension : ChartDimension) -> [AggregatedValue]
    {
        var returnValue = [AggregatedValue]()
        
        let dimensionValues = dimension.getDimensionValues(valueObjects)
        
        var i : Int = 0;
        
        for dimensionValue in dimensionValues
        {
            var aggValue : AggregatedValue = AggregatedValue(measure: self.measure,
                values: getDimensionSubset(dimension.fieldName, dimensionValue: dimensionValue, candidates: valueObjects))
            
            aggValue.dimension = dimension
            aggValue.dimensionValue = dimensionValue
            if (max < aggValue.subtotal)
            {
                max = aggValue.subtotal
            }
            
            if (min > aggValue.subtotal)
            {
                min = aggValue.subtotal
            }
            
            aggValue.parent = self
            returnValue.append(aggValue)
            i++;
        }
    
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
    
    func buildValueModelTree(dimensions : [ChartDimension]) -> Void
    {
        if (dimensions.isEmpty)
        {
            return
        }
        
        var localDimensions = dimensions;
        self.dimension = localDimensions.first;
        
        children = buildValueModel(self.dimension!);
        
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
            println("\(self.getValuePath())(\(self.subtotal))");
        }
        
        for (value) in children
        {
            value.printTree()
        }
    }
}
