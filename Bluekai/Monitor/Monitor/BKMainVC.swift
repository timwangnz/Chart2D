//
//  ViewController.swift
//  Monitor
//
//  Created by Anping Wang on 6/22/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class BKMainVC: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    //model
    var commands = ["Pixel Servers" : ["CFR", "Offline Status", "Delivery", "Offline Ingestion"],
        "Inventory" : ["Inventory"]
        ,"Mobile SDK" : ["SDK Demo"]
        ,"Partner 360" : ["Bluekai", "Partner"]]
    
    var sortedKeys = [ "Partner 360", "Inventory", "Mobile SDK", "Pixel Servers"]
    
  
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedKeys.count;
    }
   
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedKeys[section];
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sortedKeys[section];
        if let rows = commands[key]
        {
            return rows.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let key = sortedKeys[indexPath.section];
        
        if let rows = commands[key]
        {
            cell.textLabel!.text = rows[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key = sortedKeys[indexPath.section];
        
        if let rows = commands[key]
        {
             let navvc = self.navigationController;
            let selected = rows[indexPath.row]
            
            if selected == "Inventory"
            {
                var sqlGraphVC = BKInventoryVC(nibName: "BKInventoryVC", bundle: nil);
                
                
                println("Go get data")
                sqlGraphVC.refresh { (data, error) -> Void in
                    if (error == nil)
                    {
                        println("got data \(data)")
                        dispatch_async(dispatch_get_main_queue(), {
                            navvc!.pushViewController(sqlGraphVC, animated: true )
                        })
                        
                    }
                }
            }
            else if selected == "SDK Demo"
            {
                var sdkVC = BKSDKDemoVC(nibName: "BKSDKDemoVC", bundle: nil);
                navvc!.pushViewController(sdkVC , animated: true )

            }
            else if selected == "Bluekai"
            {
                var sdkVC = BkDBTablesVC(nibName: "BkDBTablesVC", bundle: nil);
                sdkVC.limit = 5000;
                println("Go get data")
                sdkVC.refresh { (data, error) -> Void in
                    if (error == nil)
                    {
                        println("got data \(data)")
                        dispatch_async(dispatch_get_main_queue(), {
                            navvc!.pushViewController(sdkVC, animated: true )
                        })
                        
                    }
                }

            }
            
        }
    }
}

