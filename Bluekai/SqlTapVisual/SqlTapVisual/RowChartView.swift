//
//  AggregatedView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/6/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class RowChartView: NSObject {
    var chartViews : [ChartView]  = []
    var aggregatedValue:AggregatedValue? = nil
    
    var max : Double? = nil;
    var min : Double? = nil;
    
    func drawLabel(contentView : UIView)
    {
        if (chartViews.count > 0)
        {
            let firstChild = chartViews[0]
            
            let label = UILabel(frame: CGRectZero)
            
            label.textColor = UIColor.whiteColor()
            //label.center = chartView.center
            
            label.textAlignment = NSTextAlignment.Center
            label.text = aggregatedValue?.measure.fieldName
            label.frame = CGRectMake(0, 100, 200, 21)
            
            label.center = CGPointMake(40, firstChild.frame.origin.y + firstChild.getGraphBounds().size.height/2)
            
            label.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2));
            contentView.addSubview(label)
        }
        
    }
    
    func addSubview(chartView : ChartView)
    {
        chartViews.append(chartView)
    }
    
    func roundMax(value : Double)->Double
    {
        if(value > 0)
        {
            var degree : Int = 0;
            var dValue = value;
            while (dValue > 10) {
                dValue = dValue / 10
                degree--
            }
            let power = pow(Double(10), Double(degree))
            
            let hStep = ceil(value * power)/power/10
            
            for var i = 0; i<10; i++
            {
                if (value < Double(i) * hStep)
                {
                    return Double(i) * hStep;
                }
            }
        }
        return value;
    }

    func roundMin(value : Double)->Double
    {
        if(value > 0)
        {
            return roundMax(value)
        }
        else if (value < 0)
        {
            var newValue = -value
            newValue = roundMax(newValue)
            return -newValue
        }
        return value
    }
    
    func scale()
    {
        min = 10000000000000000;
        max = -10000000000000000;
        
        if (aggregatedValue!.hasSubDimensions == true)
        {
           
            for child in aggregatedValue!.children
            {
                if (child.maxOfChildren > max)
                {
                    max = child.maxOfChildren
                }
                if (child.minOfChildren < min)
                {
                    min = child.minOfChildren
                }
            }
        }
        else
        {
            max = aggregatedValue!.max
            min = aggregatedValue!.min
            if (aggregatedValue?.children.count == 0)
            {
                max = Double(aggregatedValue!.getValue());
                min = 0;
            }
            else
            {
                min = aggregatedValue!.minOfChildren
                max = aggregatedValue!.maxOfChildren
            }
        }
        
        if (min > 0)
        {
            min = 0;
        }
        
        for chartView in chartViews
        {
            chartView.autoScaleMode = Graph2DAutoScaleNone
            chartView.yMax = CGFloat(roundMax(max!))
            chartView.yMin = CGFloat(roundMin(min!))
        }
    }
}
