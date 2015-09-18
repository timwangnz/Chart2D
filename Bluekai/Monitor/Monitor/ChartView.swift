//
//  BKSqlChartView.swift
//  Monitor
//
//  Created by Anping Wang on 7/4/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class ChartView: Graph2DChartView{
    var title : String = ""
    var limit : Int = 0
    var cacheTTL : Int = -1
    var xLabelField : String = ""
    
    var activityView : UIActivityIndicatorView
    
    required init?(coder aDecoder: NSCoder) {
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
        super.refresh();
    }
    
}
