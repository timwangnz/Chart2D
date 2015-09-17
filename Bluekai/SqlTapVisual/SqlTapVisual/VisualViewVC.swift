//
//  DetailViewController.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

let MIN_CHART_WIDTH = 240
let DEFAULT_BAR_WIDTH = 20

class VisualViewVC: UIViewController, DragableViewModelDelegate{
    
    var draggle  = DragableViewModel()
    var rowdraggle = DragableViewModel()
    
    @IBOutlet var columnsView: DroppableView!
    @IBOutlet var rowsView: DroppableView!
    
    @IBOutlet var sizeMark: DroppableView!
    @IBOutlet var colorMark: DroppableView!
    @IBOutlet var filtersView: DroppableView!
    @IBOutlet var pagesView: DroppableView!
    @IBOutlet var controlsView: DroppableView!
    
    @IBOutlet var labelMark: DroppableView!
    
    var chartViews : [ChartView]  = []
    var rowViews : [RowChartView]  = []

    @IBOutlet var containerView: UIScrollView!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    let panRec = UIPanGestureRecognizer()
    
    var model : VisualizationModel?
        {
        didSet {
            self.configureView()
        }
    }
    
    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }


    func initView(chartView : ChartView, col:Int, row:Int)
    {
        chartView.borderStyle = BorderStyle4Sides;
        chartView.drawXGrids = true
        chartView.drawYGrids = true
        
        chartView.fillStyle = nil
        chartView.autoScaleMode = Graph2DAutoScaleMax;
        chartView.touchEnabled = true
      //  chartView.cursorType = Graph2DChartCursorType.
        
        chartView.topMargin = row == 0 ? 20 : 10
        chartView.bottomMargin = row != model!.measures.count - 1 ? 10 : 80;
        chartView.leftMargin = 100
        chartView.topPadding = 0
        chartView.legendType = Graph2DLegendNone
        chartView.xAxisStyle.labelStyle.angle = CGFloat(1.0*M_PI/4.0)

        chartView.yMin = 0
        chartView.barChartStyle = BarStyleCluster
        chartView.chartType = Graph2DBarChart //Graph2DLineChart
        chartView.cursorType = Graph2DCursorNone
        chartView.hidden = true
        chartView.autoScaleMode = Graph2DAutoScaleMax
        chartView.drawBorder = true
    }
    
    func drop(view : UIView, from:UIView, to:UIView)
    {
        if(from.isEqual(columnsView))
        {
            if (to.isEqual(columnsView))
            {
                //does nothing
            }
            else
            {
                self.model!.deleteDimensionAt(view.tag);
            }
        }
        if (from.isEqual(rowsView))
        {
            if (from.isEqual(columnsView))
            {
                //does nothing
            }
            else
            {
                self.model!.deleteMeasureAt(view.tag);
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.draggle.setup(columnsView)
        self.rowdraggle.setup(rowsView)
        self.draggle.delegate = self;
        self.rowdraggle.delegate = self;
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "dimensionsChanged",
            name: "VisualizationModel.columns.changed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "measuresChanged",
            name: "VisualizationModel.rows.changed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "tableChanged",
            name: "VisualizationModel.table.changed", object: nil)
    }
    
    func tableChanged()
    {
        model!.measuresChanged()
        layoutColumns()
        layoutRows()
        updateChart()
    }
    
    func dimensionsChanged() {
        layoutColumns()
        updateChart()
    }
    
    func measuresChanged() {
        layoutRows()
        updateChart()
    }
    
    func resetContentView()
    {
        if let content = contentView
        {
            if (content.subviews.count > 0)
            {
                for view in content.subviews
                {
                    view.removeFromSuperview()
                }
            }
            content.removeFromSuperview()
        }
        contentWidth = CGFloat(0)
        contentHeight = CGFloat(0)
        chartViews.removeAll(keepCapacity: false)
        rowViews.removeAll(keepCapacity: false)
        contentView = UIView(frame: CGRectZero)
    }
    
    func updateChart()
    {
        resetContentView()
        
        var min : Double = 10000000000000000.0
        var max : Double = -10000000000000000.0
        let rows = CGFloat(model!.measures.count)
        var i = 0
        for row in model!.measures
        {
            var rowView = RowChartView()
            rowViews.append(rowView)
            
            let aggregatedValue = model!.aggregatedModel[row.fieldName]
            var j = 0
            rowView.aggregatedValue = aggregatedValue
            let children = aggregatedValue?.children
                
            if (aggregatedValue?.hasSubDimensions == true)
            {
                for child in children!
                {
                    if (child.max > max)
                    {
                        max = child.max
                    }
                    if (child.min < min)
                    {
                        min = child.min
                    }
                    let chartView = createView(child, row: i, col: j, rows: rows, yAxis:false)
                    
                    if (i == 0)
                    {
                        let label = UILabel(frame: CGRectMake(0, 0, chartView.contentSize.width, 21))
                        label.textColor = UIColor.redColor()
                        label.textAlignment = NSTextAlignment.Center
                        label.text = "\(child.dimensionValue!)"
                        chartView.addSubview(label);
                    }
                
                    if (j == 0)
                    {
                        let axisView = createView(child, row: i, col: j, rows: rows, yAxis:true)
                         rowView.addSubview(axisView)
                    }
                    rowView.addSubview(chartView)
                    j++
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
                
                let chartView = createView(aggregatedValue!, row: i, col: j, rows: rows, yAxis: false)
                rowView.addSubview(chartView)
                let axisView = createView(aggregatedValue!, row: i, col: j, rows: rows, yAxis: true)
                rowView.addSubview(axisView)
            }
            aggregatedValue!.max = max
            aggregatedValue!.min = min
            i++
        }
        
        for chartView in chartViews
        {
            contentView.addSubview(chartView)
        }
        
        autosizeScrollView(contentView)
        containerView.addSubview(contentView);
    }
    
    var contentWidth :CGFloat = CGFloat(0)
    var contentHeight : CGFloat = CGFloat(0)
    
    func autosizeScrollView(contentView : UIView) -> Void
    {
        contentView.frame.size = CGSizeMake(contentWidth, contentHeight);
        let insets =
          UIEdgeInsets(top: 0, left: 0, bottom: contentHeight, right: contentWidth);
        //containerView.contentSize = CGSizeMake(contentWidth, contentHeight);
        
        containerView.contentInset = insets;
        
        containerView.contentOffset = CGPointMake(0, 0)
        
        containerView.backgroundColor = UIColor.grayColor()
        contentView.backgroundColor=UIColor.darkGrayColor()
        
        println("\(containerView.contentSize) \(contentView.frame) \(containerView.frame)   \(containerView.contentInset.top)" )
        contentView.clipsToBounds = true
        for chartView in rowViews
        {
            chartView.scale();
            chartView.drawLabel(contentView)
        }
        
        for chartView in chartViews
        {
            chartView.refresh();
        }
    }
    
    func buildColorModel(aggregatedValue:AggregatedValue) -> AggregatedValue?
    {
        if (aggregatedValue.dimension == nil || self.model?.colorMeasure == nil)
        {
            return nil
        }
        
        if let measure = self.model?.colorMeasure
        {
            var rootValue = AggregatedValue(measure: measure, values:  aggregatedValue.valueObjects)
            
            var aggregatedValues = rootValue.buildValueModel(aggregatedValue.dimension!)
            
            for aggregatedValue in aggregatedValues
            {
                rootValue.children.append(aggregatedValue)
            }
            return rootValue;
        }
        return nil
    }
    
    func createView(aggregatedValue:AggregatedValue, row :Int, col:Int, rows:CGFloat, yAxis:Bool) -> ChartView
    {
        let margin:CGFloat = 15
        let height = (self.containerView.frame.height - 80 - margin * 2) / rows
        let chartView = ChartView(frame: CGRectZero)
        chartViews.append(chartView)
        let chartModel = ChartModel()
        
        chartModel.colorModel = buildColorModel(aggregatedValue)
        
        chartModel.model = aggregatedValue;
        chartView.dataSource = chartModel
        chartView.chartDelegate = chartModel
        chartView.view2DDelegate = chartModel
        
        initView(chartView, col: col, row: row)
        
        let leftMargin = CGFloat(100);

        let columns = aggregatedValue.children.count
        var h = height
        var gap  = CGFloat(2)
        
        var width = chartView.rightMargin +  margin * 2 + CGFloat(columns * DEFAULT_BAR_WIDTH) - leftMargin;
        
        if (width < CGFloat(MIN_CHART_WIDTH))
        {
            width = CGFloat(MIN_CHART_WIDTH);
        }
        
        if row == model!.measures.count - 1
        {
            h = h + 80
        }
        
        var y = margin + (height) * CGFloat(row);
        var x = (width + gap) * CGFloat(col);

        chartView.hidden = false
        if (!yAxis)
        {
            chartView.leftMargin = margin;
            chartView.rightMargin = margin;
            chartView.yAxisStyle.labelStyle.hidden = true
            chartView.frame = CGRectMake(leftMargin + x, y, width, h)
            chartView.contentSize = CGSizeMake(width, h)
        }
        else
        {
            chartView.rightMargin = 0;
            chartView.leftMargin = leftMargin + margin;
            chartView.frame = CGRectMake(x, y, chartView.rightMargin + chartView.leftMargin, h)
            chartView.contentSize = chartView.frame.size
            
            chartView.borderStyle = BorderStyleNone
            chartView.drawContent = false
            chartView.xAxisStyle.hidden = true
        }
        
        if (contentWidth < chartView.contentSize.width + chartView.frame.origin.x)
        {
            contentWidth = CGFloat(chartView.contentSize.width + chartView.frame.origin.x)
        }
        
        if (contentHeight < chartView.contentSize.height + chartView.frame.origin.y)
        {
            contentHeight = CGFloat(chartView.contentSize.height + chartView.frame.origin.y)
        }
        
        return chartView;
    }
    
    func createButton(title : String, bg:UIColor, at : CGPoint) -> UIButton
    {
        let button : UIButton = UIButton()
        button.frame = CGRectMake(at.x, at.y, CGFloat(120), CGFloat(24))
        button.backgroundColor = bg
        button.setTitle(title, forState: UIControlState.Normal)
        button.titleLabel!.font =  UIFont.systemFontOfSize(12)
        button.layer.cornerRadius = 4.0
        button.clipsToBounds = true
        return button;
    }
    
    
    
    func layoutColumns()
    {
        for view:UIView in columnsView.subviews as! Array<UIView>
        {
            view .removeFromSuperview();
        }
        var x : CGFloat = 5;
        var i : Int = 0;
        
        for column in model!.dimensions
        {
            var button = createButton(column.fieldName, bg:UIColor.lightGrayColor(), at:CGPointMake(x, columnsView.frame.size.height/2 - 12))
            button.tag = i
            button.addTarget(self, action: "configDimension:", forControlEvents: UIControlEvents.TouchUpInside)
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
        for row in model!.measures
        {
            var button = createButton(row.fieldName, bg:UIColor.brownColor(), at:CGPointMake(x, columnsView.frame.size.height/2 - 12))
            button.tag = i
            button.addTarget(self, action: "configMeasure:", forControlEvents: UIControlEvents.TouchUpInside)
            rowsView.addSubview(button);
            x = x + 125
            i = i + 1
        }
    }
    
    func configMeasure(sender : AnyObject)
    {
        let btn = sender as! UIButton
        let vc = MeasureConfigVC(nibName: "MeasureConfigVC", bundle: nil)
        vc.parentVC = self
        vc.measure = model!.measures[btn.tag]
        vc.modalPresentationStyle = .Popover
        let popRect = sender.frame
        let aPopover =  UIPopoverController(contentViewController: vc)
        aPopover.presentPopoverFromRect(popRect, inView: btn.superview!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    func configDimension(sender : AnyObject)
    {
        let btn = sender as! UIButton
        let vc = DimensionConfigVC(nibName: "DimensionConfigVC", bundle: nil)
        vc.modalPresentationStyle = .Popover
        vc.parentVC = self
        vc.dimension = model!.dimensions[btn.tag]
        let popRect = sender.frame
        let aPopover =  UIPopoverController(contentViewController: vc)
        aPopover.presentPopoverFromRect(popRect, inView: btn.superview!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
}

