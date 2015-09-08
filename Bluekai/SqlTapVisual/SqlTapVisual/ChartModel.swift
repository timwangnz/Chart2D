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
    var model : AggregatedValue?
    
    
    func numberOfItems(graph2Dview: Graph2DView!, forSeries graph: Int) -> Int {
        return model!.children.count == 0 ? 1 : model!.children.count
    }
    
    func numberOfSeries(graph2Dview: Graph2DView!) -> Int {
        return 1
    }
    
    func graph2DView(graph2DView: Graph2DView!, yLabelAt y: Double) -> String! {
        return "\(y)";
    }
    
    func graph2DView(graph2DView: Graph2DView!, xLabelAt x: Int) -> String {
        if (model!.children.count == 0)
        {
            return "Total"
        }
        else
        {
            var i = x;
            
            if (i > model!.children.count - 1)
            {
                i = model!.children.count - 1
            }
            return "\(model!.children[i].dimensionValue!)"
        }
    }
    
    func graph2DView(graph2DView: Graph2DView!, valueAtIndex item: Int, forSeries series: Int) -> NSNumber!
    {
        if (model!.children.count == 0){
            return model?.subtotal
        }
        else
        {
            return model!.children[item].subtotal
        }
    }
    
}
