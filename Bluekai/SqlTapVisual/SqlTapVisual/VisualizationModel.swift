//
//  VisualizationModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/6/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import Foundation
import Chart2D

class VisualizationModel: NSObject, DraggableDelegate {

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
    
    func deleteMeasure(index:Int)
    {
        let row = measures[index];
        if row.fieldName == "COUNTS"
        {
            self.counting = false
        }
        measures.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: measures)
    }
    
    func deleteDimension(index:Int)
    {
        dimensions.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: dimensions)
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
            measures.append(measure)
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: measures)
        }
    }
    
    func addDimension(dimension:Dimension)
    {
        if !contains(dimensions, dimension)
        {
            dimensions.append(dimension)
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
    
}
