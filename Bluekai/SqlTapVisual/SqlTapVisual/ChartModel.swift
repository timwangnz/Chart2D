//
//  ChartModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/18/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class ChartModel: NSObject, Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate {
    var model : AggregatedValue?
    var colorModel : AggregatedValue?
        {
        didSet {
           //should refresh the view
        }
    }

    
    var seriesStyle = Graph2DSeriesStyle.defaultStyle(Graph2DLineChart)
    
    var lineStyle = Graph2DLineStyle()
    
    override init()
    {
        seriesStyle.chartType = Graph2DBarChart;
        seriesStyle.color = UIColor.yellowColor()
        seriesStyle.gradient = true;
        seriesStyle.lineStyle.penWidth = 1;
    }
    
    func numberOfItems(graph2Dview: Graph2DView!, forSeries graph: Int) -> Int {
        return model!.children.count == 0 ? 1 : model!.children.count
    }
    
    func numberOfSeries(graph2Dview: Graph2DView!) -> Int {
        return 1
    }
    
    func graph2DView(graph2DView: Graph2DView!, yLabelAt y: Double) -> String! {
        return model!.measure.formatObject(y)
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
            return model?.getValue()
        }
        else
        {
            return model!.children[item].getValue()
        }
    }
    
    func _indexToColor(index:Int) -> UIColor
    {
        let c = CGFloat(index)/CGFloat(16)
        return getHeatMapColor(c);
    }
    
    func indexToColor(index:Int) -> UIColor
    {
        var c = CGFloat(index)/CGFloat(16)
        if c <= 1
        {
            return UIColor(red: c, green: 1.0, blue: 1.0, alpha: 1)
        }
        else
        {
            c = CGFloat(index - 8)/CGFloat(8)
            
            return UIColor(red: 0.0, green: c, blue: 0.0, alpha: 1)
        }
    }
    
    func getHeatMapColor(value : CGFloat) -> UIColor
    {
        let NUM_COLORS = 4
        
        let color = [[0,0,1], [0,1,0], [1,1,0], [1,0,0]]
        
        // A static array of 4 colors:  (blue,   green,  yellow,  red) using {r,g,b} for each.
        
        var idx1 = 0             // |-- Our desired color will be between these two indexes in "color".
        var idx2 = 0             // |
        var fractBetween = CGFloat(0.0)  // Fraction between "idx1" and "idx2" where our value is.
        var dv = value
        if(dv <= 0)
        {
            idx1 = 0
            idx2 = 0
        }    // accounts for an input <=0
        else if(dv >= 1)  {
            idx1 = NUM_COLORS-1
            idx2 = NUM_COLORS-1
        }    // accounts for an input >=0
        else
        {
            dv = dv * CGFloat((NUM_COLORS - 1)); // Will multiply value by 3.
            idx1  = Int(floor(dv))                  // Our desired color will be after this index.
            idx2  = idx1 + 1;                   // ... and before this index (inclusive).
            fractBetween = dv - CGFloat(idx1);   // Distance between the two indexes (0-1).
        }
        
        let red   = CGFloat(color[idx2][0] - color[idx1][0]) * fractBetween + CGFloat(color[idx1][0])
        let green = CGFloat(color[idx2][1] - color[idx1][1]) * fractBetween + CGFloat(color[idx1][1])
        _  = CGFloat(color[idx2][2] - color[idx1][2]) * fractBetween + CGFloat(color[idx1][2])
        return UIColor(red: red, green: green, blue: green, alpha: 1.0)
    }
    
    func getColor(min : Double, max : Double, value:Double)->UIColor
    {
        //println("\(min) \(max) \(value)")
        
        let step = (max - min) / Double(16)
        for var i = 0; i < 16; i++
        {
            if (value >= (max - Double(i) * step))
            {
                return indexToColor(i)
            }
        }
        return indexToColor(0)
    }
    
    //protocols
    func graph2DView(graph2DView: Graph2DChartView!, didSelectSeries series: Int, atIndex index: Int) {
        if (index >= 0 && index < self.model?.children.count)
        {
            if let dimValue = self.model?.children[index]
            {
                print("clicked  \(dimValue.dimension!.fieldName) = \(dimValue.dimensionValue!)")
            }
        }
    }
    
    func graph2DView(graph2DView: Graph2DChartView!, styleForSeries series: Int, atIndex index: Int) -> Graph2DSeriesStyle! {
        if (self.colorModel != nil && index < self.colorModel?.children.count)
        {
            if let number = self.colorModel?.children[index]
            {
                seriesStyle.color = getColor(self.colorModel!.minOfChildren, max: self.colorModel!.maxOfChildren, value: number.getValue());
            }
        }
        return seriesStyle;
    }
    
    func borderLineStyle(graph2DView: Graph2DView!) -> Graph2DLineStyle! {
        lineStyle.color = UIColor.whiteColor()
        lineStyle.penWidth = 0.1
        lineStyle.lineType = LineStyleSolid
        return lineStyle
    }
    
    func xAxisStyle(graph2DView: Graph2DChartView!) -> Graph2DAxisStyle! {
        if graph2DView.chartType == Graph2DBarChart
        {
            graph2DView.xAxisStyle.tickStyle.majorTicks = self.numberOfItems(graph2DView, forSeries: 0)
        }
        return graph2DView.xAxisStyle
    }
    
    func yAxisStyle(graph2DView: Graph2DChartView!) -> Graph2DAxisStyle! {
        return graph2DView.yAxisStyle
    }

}
