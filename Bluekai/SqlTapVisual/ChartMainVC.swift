//
//  SqlMainVC.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class ChartMainVC: UITableViewController, UITableViewDelegate, UITableViewDataSource{

    var model : VisualizationModel = VisualizationModel()
    var draggle : DragableCellModel = DragableCellModel()

    var sortedKeys = [ "Dimensions", "Measures"]

    override func viewDidLoad() {
        super.viewDidLoad()
        model.resetModel()
        draggle.setup(tableView)
        draggle.delegate = model
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedKeys.count;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section];
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return model.dataSource.dimensions.count
        }
        else
        {
            return model.dataSource.measures.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MasterVCCell") as! UITableViewCell

        cell.selectionStyle = .None
        
        var row : ChartField
        
        if (indexPath.section == 0)
        {
            row = model.dataSource.dimensions[indexPath.row]
        }
        else
        {
            row = model.dataSource.measures[indexPath.row]
        }
        
        cell.textLabel!.text = row.fieldName
       
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section == 0)
        {
            model.addDimension(model.dataSource.dimensions[indexPath.row])
        }
        else
        {
            model.addMeasure(model.dataSource.measures[indexPath.row])
        }
    }
}

