//
//  ChartModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/18/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class ChartModel: NSObject, Graph2DDataSource {
    var globalModel : VisualizationModel?
    var rowName : String?
    var colName : String?
    
    func numberOfItems(graph2Dview: Graph2DView!, forSeries graph: Int) -> Int {
        return globalModel!.aggregatedModel[self.rowName!]!.count
    }
    
    func numberOfSeries(graph2Dview: Graph2DView!) -> Int {
        return 1
    }
    
    func graph2DView(graph2DView: Graph2DView!, yLabelAt y: Double) -> String! {
        return String(format: "%.0f", y)//"\(y)"
    }
    
    func graph2DView(graph2DView: Graph2DView!, xLabelAt x: Int) -> String {
        return globalModel!.aggregatedModel[self.rowName!]!.getDimensionValueAt(x)
    }
    
    func graph2DView(graph2DView: Graph2DView!, valueAtIndex item: Int, forSeries series: Int) -> NSNumber! {
        let object: NSDictionary = globalModel!.aggregatedModel[rowName!]!.valueObjects[item] as! NSDictionary
        var cName = rowName!
        let value: AnyObject = object[cName]!
        if value.isKindOfClass(NSNumber)
        {
            return value as! NSNumber
        }
        else
        {
            let nValue = (value as! NSString).floatValue
            return nValue
        }
    }
}
