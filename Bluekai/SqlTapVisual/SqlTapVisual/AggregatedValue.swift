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
    
    
    var measure : ChartField
    
    var dimension : ChartField?
    var dimensionValue : String?
    
    var children = [String: AggregatedValue]()
    var childDimensionValues = [String]()
    
    var parent : AggregatedValue?
    
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
        for (name, child) in children
        {
            path.append(name)
        }
        return path
    }
    
    func getDimensionSubset(dimensionName:String, dimensionValue : String, candidates:NSMutableArray) -> NSMutableArray
    {
        var subset : NSMutableArray = []
        for element in candidates
        {
            if dimensionValue == element[dimensionName] as! String
            {
                subset.addObject(element);
            }
        }
        return subset;
    }
    
    func getDistinctDimensionValues(dimension : String, candidates:NSMutableArray) -> [String]
    {
        var categories = [String]()
        
        for element in candidates
        {
            if let value = element[dimension]  as? String
            {
                if (!contains(categories, value))
                {
                    categories.append(value);
                }
            }
        }
        return categories
    }
    
    func buildValueModel(var dimension : ChartField) -> [String : AggregatedValue]
    {
        var returnValue = [String : AggregatedValue]()
        
        let dimensionValues = getDistinctDimensionValues(dimension.fieldName, candidates: valueObjects)
        for dimensionValue in dimensionValues
        {
            var aggValue : AggregatedValue =
                AggregatedValue(measure: self.measure, values: getDimensionSubset(dimension.fieldName, dimensionValue: dimensionValue, candidates: valueObjects));
            
            aggValue.dimension = dimension
            aggValue.dimensionValue = dimensionValue
            aggValue.parent = self;
            
            returnValue.updateValue(aggValue, forKey: dimensionValue)
            
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
    
    func buildValueModelTree(dimensions : [ChartField]) -> Void
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
            for (dimensionValue, aggregatedValue) in children
            {
                aggregatedValue.parent = self;
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
        
        for (dimValue, value) in children
        {
            value.printTree()
        }
    }
}
