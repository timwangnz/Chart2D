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


    //protocols
    func graph2DView(graph2DView: Graph2DChartView!, styleForSeries series: Int) -> Graph2DSeriesStyle! {
        var legend: String = ""
        
        seriesStyle.legend = Graph2DLegendStyle(text: legend, color: seriesStyle.color, font: UIFont.systemFontOfSize(10))
        return seriesStyle;
    }
    
    func borderLineStyle(graph2DView: Graph2DView!) -> Graph2DLineStyle! {
        lineStyle.color = UIColor.whiteColor()
        lineStyle.penWidth = 0.1
        lineStyle.lineType = LineStyleSolid
        return lineStyle
    }
    
    func setColorDimension(dim : Dimension)
    {
        
    }
    
    func setSizeDimension(dim : Dimension)
    {
        
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
