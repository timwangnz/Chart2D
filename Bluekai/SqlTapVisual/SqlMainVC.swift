//
//  SqlMainVC.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class SqlMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var model : VisualizationModel = VisualizationModel()
    var draggle : BkDragableCellModel = BkDragableCellModel()
    
    @IBOutlet var tableView: UITableView!

    var sortedKeys = [ "Dimensions", "Measures"]

    override func viewDidLoad() {
        super.viewDidLoad()
        model.setupData()
        draggle.setup(tableView)
        draggle.delegate = model
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedKeys.count;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section];
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return model.dimensions.count
        }
        else
        {
            return model.measures.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MasterVCCell") as! UITableViewCell

        cell.selectionStyle = .None
        
        var row : NSDictionary?
        
        if (indexPath.section == 0)
        {
            row = model.dimensions[indexPath.row] as? NSDictionary
        }
        else
        {
            row = model.measures[indexPath.row] as? NSDictionary
        }
        
        cell.textLabel!.text = row?.objectForKey("COLUMN_NAME") as? String
       
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row : NSDictionary?
        
        if (indexPath.section == 0)
        {
            row = model.dimensions[indexPath.row] as? NSDictionary
            model.addColumn(row!)
        }
        else
        {
            row = model.measures[indexPath.row] as? NSDictionary
            model.addRow(row!)
        }
    }
}

