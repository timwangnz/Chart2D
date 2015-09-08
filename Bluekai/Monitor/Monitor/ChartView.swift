//
//  BKSqlChartView.swift
//  Monitor
//
//  Created by Anping Wang on 7/4/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class ChartView: Graph2DChartView, Graph2DChartDelegate, Graph2DViewDelegate{
    var title : String = ""
    var limit : Int = 0
    var cacheTTL : Int = -1
    var xLabelField : String = ""
    var seriesStyle = Graph2DSeriesStyle.defaultStyle(Graph2DLineChart)
    var activityView : UIActivityIndicatorView
    
    required init(coder aDecoder: NSCoder) {
        activityView = UIActivityIndicatorView();
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect) {
        activityView = UIActivityIndicatorView();
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        super.init(frame:frame);
    }
    
    override func drawRect(rect:CGRect) ->Void
    {
        activityView.center = self.convertPoint(self.center, fromView: self.superview)
        super.drawRect(rect);
    }
    
    override func refresh() {
        self.activityView.stopAnimating();
        self.activityView.hidden = true;
        self.activityView.removeFromSuperview();
        self.chartDelegate = self;
        self.view2DDelegate = self;
        seriesStyle.chartType = self.chartType;
        seriesStyle.color = UIColor.yellowColor()
        seriesStyle.gradient = true;
        seriesStyle.lineStyle.penWidth = 1;
        super.refresh();
    }
    
    var lineStyle = Graph2DLineStyle();
    //protocols
    func graph2DView(graph2DView: Graph2DView!, styleForSeries series: Int) -> Graph2DSeriesStyle! {
        var legend: String = ""
        if (self.displayNames != nil)
        {
            legend = self.displayNames[legend]! as! String;
        }
        seriesStyle.legend = Graph2DLegendStyle(text: legend, color: seriesStyle.color, font: UIFont.systemFontOfSize(10))
        return seriesStyle;
    }
    
    func borderLineStyle(graph2DView: Graph2DView!) -> Graph2DLineStyle! {
        lineStyle.color = UIColor.whiteColor()
        lineStyle.penWidth = 0.1
        lineStyle.lineType = LineStyleSolid
        return lineStyle
    }
    
    func xAxisStyle(graph2DView: Graph2DView!) -> Graph2DAxisStyle! {
        if graph2DView.chartType == Graph2DBarChart
        {
            xAxisStyle.tickStyle.majorTicks = self.dataSource.numberOfItems(self, forSeries: 0)
        }
        return self.xAxisStyle
    }
    
    func yAxisStyle(graph2DView: Graph2DView!) -> Graph2DAxisStyle! {
        return self.yAxisStyle
    }
}
