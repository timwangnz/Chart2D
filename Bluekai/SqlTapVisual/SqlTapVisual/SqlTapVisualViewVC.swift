//
//  DetailViewController.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class SqlTapVisualViewVC: UIViewController {
    
    @IBOutlet var columnsView: UIView!
    @IBOutlet var rowsView: UIView!
    
    var chartViews : [BKSqlChartView]  = []
    //BKSqlChartView
    
    //var sqlChartView1 : BKSqlChartView? = nil
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var model : VisualizationModel?
        {
        didSet {
            self.configureView()
        }
    }
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
            
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }
    
    func initView(sqlView : BKSqlChartView)
    {
        sqlView.borderStyle = BorderStyle4Sides;
        sqlView.drawXGrids = true
        sqlView.drawYGrids = true
        
        sqlView.fillStyle = nil
        sqlView.autoScaleMode = Graph2DAutoScaleMax;
        sqlView.touchEnabled = false
        sqlView.view2DDelegate = sqlView;
        
        sqlView.topMargin = 20
        sqlView.bottomMargin = 80
        sqlView.leftMargin = 40
        sqlView.topPadding = 0
        sqlView.legendType = Graph2DLegendNone
        sqlView.xAxisStyle.labelStyle.angle = CGFloat(M_PI/2.0)
        
        sqlView.yMin = 0
        sqlView.barChartStyle = BarStyleCluster
        sqlView.chartType = Graph2DBarChart
        sqlView.cursorType = Graph2DCursorCross
        sqlView.hidden = true
        sqlView.autoScaleMode = Graph2DAutoScaleMax
        sqlView.drawBorder = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        chartViews.append(BKSqlChartView(frame: CGRectZero))
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "columnsChanged:",
            name: "VisualizationModel.columns.changed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "rowsChanged:",
            name: "VisualizationModel.rows.changed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "tableChanged:",
            name: "VisualizationModel.table.changed", object: nil)
        
    }
    
    func tableChanged(object : AnyObject)
    {
        layoutColumns();
        layoutRows();
        updateChart();
    }

    func updateChart()
    {
        for sqlChartView in chartViews
        {
            containerView.addSubview(sqlChartView)
            initView(sqlChartView);
            sqlChartView.dataSource = self.model!
            let margin:CGFloat = 10
            let columns = model!.numberOfValues()
            if (columns == 0)
            {
                sqlChartView.hidden = true
            }
            else
            {
                sqlChartView.hidden = false
                let width = sqlChartView.leftMargin + sqlChartView.rightMargin +  margin * 2 + CGFloat(columns * 30)
                let height = self.containerView.frame.height / 2 - margin * 2
                sqlChartView.frame = CGRectMake(margin, margin, width, height)
                sqlChartView.refresh();
            }
        }
    }

    func layoutColumns()
    {
        for view:UIView in columnsView.subviews as! Array<UIView>
        {
            view .removeFromSuperview();
        }
        var x : CGFloat = 5;
        var i : Int = 0;
        
        for column in model!.chartColumns
        {
            let button : UIButton = UIButton()
            button.frame = CGRectMake(x, columnsView.frame.size.height/2 - 12, CGFloat(120), CGFloat(24))
            button.backgroundColor = UIColor.grayColor()
            let name = column["COLUMN_NAME"] as! String
            button.tag = i
            button.setTitle(name, forState: UIControlState.Normal)
            button.addTarget(self, action: "deleteColumn:", forControlEvents: UIControlEvents.TouchUpInside)
            columnsView.addSubview(button);
            x = x + 125
            i = i + 1
        }
    }
    
    func layoutRows()
    {
        for view:UIView in rowsView.subviews as! Array<UIView>
        {
            view .removeFromSuperview();
        }
        var x : CGFloat = 5;
        var i : Int = 0;
        for row in model!.chartRows
        {
            let button : UIButton = UIButton()
            button.frame = CGRectMake(x, rowsView.frame.size.height/2 - 12, CGFloat(120), CGFloat(24))
            button.backgroundColor = UIColor.grayColor()
            
            let name = row["COLUMN_NAME"] as! String
            button.tag = i
            
            button.setTitle(name, forState: UIControlState.Normal)
            button.addTarget(self, action: "deleteRow:", forControlEvents: UIControlEvents.TouchUpInside)
            rowsView.addSubview(button);
            x = x + 125
            i = i + 1
        }
    }
    
    func columnsChanged(object: AnyObject) {
        layoutColumns();
        updateChart();
    }
    
    func rowsChanged(object: AnyObject) {
        layoutRows();
        updateChart();
    }
    
    func deleteRow(sender : AnyObject)
    {
        model!.deleteRowAt(sender.tag)
    }
    
    func deleteColumn(sender : AnyObject)
    {
        model!.deleteColumnAt(sender.tag)
    }
}

