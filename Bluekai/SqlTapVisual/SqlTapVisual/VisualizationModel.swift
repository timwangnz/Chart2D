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
    var chartRows = [ChartField]()
    var chartColumns = [ChartDimension]()

    var counting : Bool = false;
    
    func swap(from: NSIndexPath, to: NSIndexPath) {
        //
    }

    func resetModel()
    {
        chartColumns.removeAll(keepCapacity: false);
        chartRows.removeAll(keepCapacity: false);
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.table.changed", object: nil)
    }
    
    func deleteRowAt(index:Int)
    {
        let row = chartRows[index];
        if row.fieldName == "COUNTS"
        {
            self.counting = false
        }
        chartRows.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: chartRows)
    }
    
    func deleteColumnAt(index:Int)
    {
        chartColumns.removeAtIndex(index);
        updateModel();
        NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: chartColumns)
    }
    
    func addRow(row : ChartField)
    {
        if !contains(chartRows, row)
        {
            if(self.counting)
            {
                return;
            }
            
            if row.fieldName == "COUNTS"
            {
                self.counting = true
            }
            chartRows.append(row)
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.rows.changed", object: chartRows)
        }
    }
    
    func addColumn(column:ChartDimension)
    {
        if !contains(chartColumns, column)
        {
            chartColumns.append(column)
           
            updateModel();
            NSNotificationCenter.defaultCenter().postNotificationName("VisualizationModel.columns.changed", object: chartColumns)
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
        for measure in self.chartRows //for each measure
        {
            var rootValue = AggregatedValue(measure: measure, values: dataSource.objects)
            rootValue.buildValueModelTree(self.chartColumns);
            aggregatedModel.updateValue(rootValue, forKey: measure.fieldName)
        }
    }
    
}
