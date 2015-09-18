//
//  BKRestVC.swift
//  Monitor
//
//  Created by Anping Wang on 6/22/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class RestfulDataVC: UIViewController {
    
    @IBOutlet var dataTableView: UITableView!
    
    var titleField:NSString?
    var detailField:NSString?
    
    let data = RestfulDataSource()
    var displayNames : NSDictionary?
    var keys : NSArray?
    var filteredValues : NSArray?
    var values : NSArray?
    var limit : Int = 30
    
    let dateFormatter : NSDateFormatter = NSDateFormatter()
    
    func today() -> String{
        dateFormatter.dateFormat = "dd-MM-yyyy" // superset of OP's format
        return dateFormatter.stringFromDate(NSDate())
    }
 
    override func viewWillAppear(animated: Bool) {
        updateModel();
    }
    
    func getSql() -> String?
    {
        return nil
    }
    
    func updateModel() -> Void
    {
        dataTableView.reloadData();
    }
    
    func refresh(callback: (data:NSDictionary!, error: NSError!) -> Void) -> Void
    {
        data.sql = getSql()!
        data.limit = limit;
        data.get (){ (response: NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            let jsonDict:NSDictionary = RestfulDataSource.parseJSON(data!)
            self.values = jsonDict.objectForKey("data") as? NSArray
            self.filteredValues = self.values
            callback(data:jsonDict, error:error)
        };
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (values != nil)
        {
            return values!.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MyDefaultCellStyle")
        if self.detailField != nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "MyValue1CellStyle")
        }
        
        let row : NSDictionary? = filteredValues![indexPath.row] as? NSDictionary
        
        cell.textLabel!.text = row?.objectForKey(self.titleField!) as? String
        
        if self.detailField != nil
        {
            cell.detailTextLabel!.text = row?.objectForKey(self.detailField!) as? String
        }
        
        return cell
    }

}
