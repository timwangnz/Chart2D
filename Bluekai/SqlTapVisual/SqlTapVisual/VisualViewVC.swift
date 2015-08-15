//
//  DetailViewController.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class VisualViewVC: UIViewController {
    
    @IBOutlet var columnsView: UIView!
    @IBOutlet var rowsView: UIView!
    
    var chartViews : [ChartView]  = []
         
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
    
    func initView(sqlView : ChartView, col:Int, row:Int)
    {
        sqlView.borderStyle = BorderStyle4Sides;
        sqlView.drawXGrids = true
        sqlView.drawYGrids = true
        
        sqlView.fillStyle = nil
        sqlView.autoScaleMode = Graph2DAutoScaleMax;
        sqlView.touchEnabled = false
        sqlView.view2DDelegate = sqlView;
        
        sqlView.topMargin = row == 0 ? 20 : 10
        sqlView.bottomMargin = row != model!.chartRows.count - 1 ? 10 : 80;
        sqlView.leftMargin = 50
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
        //chartViews.append(BKSqlChartView(frame: CGRectZero))
        
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
            sqlChartView.removeFromSuperview()
        }
        
        chartViews.removeAll(keepCapacity: false);
        
       
        var j = 0
        let rows = CGFloat(model!.chartRows.count)
        let margin:CGFloat = 5
        
        var height = (self.containerView.frame.height - 80 - margin * 2) / rows
        
        for col in model!.chartColumns
        {
             var i = 0
            for row in model!.chartRows
            {
                let sqlChartView = ChartView(frame: CGRectZero)
                chartViews.append(sqlChartView)
                containerView.addSubview(sqlChartView)
                let chartModel = ChartModel()
                chartModel.globalModel = self.model!
                
                chartModel.rowName = row.fieldName
                chartModel.colName = model!.chartColumns[j].fieldName
                
                sqlChartView.dataSource = chartModel
                
                initView(sqlChartView, col: j, row: i)
                let columns = model!.aggregatedModel[row.fieldName]?.count
                
                if (columns == 0)
                {
                    sqlChartView.hidden = true
                }
                else
                {
                    sqlChartView.hidden = false
                    let width = sqlChartView.leftMargin + sqlChartView.rightMargin +  margin * 2 + CGFloat(columns! * 15)
                    
                    var y = margin + (height) * CGFloat(i);
                    
                    if i == model!.chartRows.count - 1
                    {
                        height = height + 80
                    }
                    
                    sqlChartView.frame = CGRectMake(margin, y, width, height)
                }
                i++;
            }
            j++;
        }
       
        for sqlChartView in chartViews
        {
            sqlChartView.refresh();
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
           
            button.tag = i
            button.setTitle(column.fieldName, forState: UIControlState.Normal)
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
           
            button.tag = i
            
            button.setTitle(row.fieldName, forState: UIControlState.Normal)
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

