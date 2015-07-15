//
//  BKDBColumnsVC.swift
//  Monitor
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class BKDBColumnsVC: BKRestVC, BkDraggableDelegate {
    
    var model : VisualizationModel?
    var draggle : BkDragableCellModel = BkDragableCellModel()
    var tableName : NSString?
    var dimensions : NSMutableArray = []
    var measures : NSMutableArray = []
    var counting : Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Data Field"
        self.titleField = "COLUMN_NAME"
        self.detailField = "DATA_TYPE"
        //dataTableView.registerClass(SqlTableViewCell.self, forCellReuseIdentifier: "MyValue1CellStyle")
        limit = 5000
        
        dataTableView.rowHeight = 50.0
        
        dataTableView.separatorStyle = .None
        draggle.setup(dataTableView)
        draggle.delegate = self
    }
    
    func swap(from: NSIndexPath, to : NSIndexPath) {
        
        if (from.section == 0)
        {
            let measure: AnyObject = measures[to.row];
            measures .removeObject(measure);
            dimensions.addObject(measure);
            println("move measures to dimension")
            dataTableView.reloadData();
        }
        else if (from.section == 1)
        {
            let dimension: AnyObject = dimensions[to.row];
            dimensions.removeObject(dimension);
            measures.addObject(dimension);
            println("move dimension to measure")
        }
    }
    
    override func updateModel() -> Void
    {
        for row in self.values!
        {
            if row["DATA_TYPE"] as? String == "NUMBER"
            {
                measures.addObject(row)
            }
            else
            {
                dimensions.addObject(row)
            }
        }
        measures.addObject(["COLUMN_NAME":"COUNTS", "DATA_TYPE":"NUMBER"])
        
        super.updateModel()
    }
    
    override func getSql() ->String?
    {
        return "select column_name, data_type from all_tab_columns where table_name='\(tableName!)' order by column_name"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0)
        {
            return dimensions.count
        }
        else
        {
            return measures.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row : NSDictionary?
        
        if (indexPath.section == 0)
        {
            row = dimensions[indexPath.row] as? NSDictionary
            model!.addColumn(row!)
        }
        else
        {
            row = measures[indexPath.row] as? NSDictionary
            model!.addRow(row!)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 0)
        {
            return "Dimensions"
        }
        else
        {
            return "Measures"
        }
    }
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = values!.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.8
        return UIColor(red: 0.7, green: val, blue: 0.7, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MyValue1CellStyle")
        cell.selectionStyle = .None
        var row : NSDictionary?
        
        
        if (indexPath.section == 0)
        {
            row = dimensions[indexPath.row] as? NSDictionary
        }
        else
        {
            row = measures[indexPath.row] as? NSDictionary
        }
        
        cell.textLabel!.text = row?.objectForKey(self.titleField!) as? String
        
        if self.detailField != nil
        {
            cell.detailTextLabel!.text = row?.objectForKey(self.detailField!) as? String
        }
        return cell
    }
}
