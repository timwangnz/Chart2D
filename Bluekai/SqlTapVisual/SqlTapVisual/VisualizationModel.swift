//
//  VisualizationModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/6/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import Foundation
import Chart2D

class VisualizationModel: NSObject, DraggableCellDelegate {

    var dataSource : StaticDataSource = StaticDataSource()
   
    var aggregatedModel = [String:AggregatedValue]()
    var measures = [Measure]()
    var dimensions = [Dimension]()

    var counting : Bool = false;
    
    func swap(from: NSIndexPath, to: NSIndexPath) {
        //
    }

    func resetModel()
    {
        dimensions.removeAll(keepCapacity: false);
        measures.removeAll(keepCapacity: false);
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.table.changed", object: nil)
    }
    
    func deleteMeasureAt(index:Int)
    {
        measures.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: measures)
    }
    
    func deleteDimensionAt(index:Int)
    {
        dimensions.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: dimensions)
    }
    
    func deleteDimension(dimension : Dimension)
    {
        if let idx = find(dimensions, dimension)
        {
            deleteDimensionAt(idx);
        }
    }
    
    func deleteMeasure(measure : Measure)
    {
        if let idx = find(measures, measure)
        {
            deleteMeasureAt(idx);
        }
    }
    
    func addMeasure(measure : Measure)
    {
        if !contains(measures, measure)
        {
            if(self.counting)
            {
                return;
            }
            
            if measure.fieldName == "COUNTS"
            {
                self.counting = true
            }
            measures.append(measure.makeNew())
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: measures)
        }
    }
    
    func addDimension(dimension:Dimension)
    {
        if !contains(dimensions, dimension)
        {
            dimensions.append(dimension.makeNew())
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: dimensions)
        }
    }
    
    func totalGroupedBy(objects : NSMutableArray, fieldName : String) -> Double
    {
        var total : Double = 0
        for object in objects
        {
            let measure: AnyObject? = object[fieldName];
            total = total + (measure as! Double)
        }
        return total;
    }
    
    func objectsGroupedBy(path:[String]) -> NSMutableArray
    {
        var children = dataSource.objects
        
        for pathEle in path
        {
            children = objectsGroupedBy(children, fieldName: pathEle)
        }
        return children;
    }
    
    func objectsGroupedBy(objects :NSMutableArray, fieldName:String) -> NSMutableArray
    {
        var groupedObjects : NSMutableArray = []
        for object in objects
        {
            if let child: AnyObject = object[fieldName]
            {
                groupedObjects.addObject(object)
            }
        }
        return groupedObjects;
    }
    
    
    func updateModel()
    {
        aggregatedModel.removeAll(keepCapacity: false);
        var i = 0
        for measure in self.measures //for each measure
        {
            var rootValue = AggregatedValue(measure: measure, values: dataSource.objects)
            rootValue.buildValueModelTree(self.dimensions);
            aggregatedModel.updateValue(rootValue, forKey: measure.fieldName)
        }
    }
    
    func measuresChanged()
    {
        updateModel()
    }
    func dimensionChanged()
    {
        updateModel()
    }
}
