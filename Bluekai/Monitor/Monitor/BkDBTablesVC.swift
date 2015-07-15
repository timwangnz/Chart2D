//
//  BkDBTablesVC.swift
//  Monitor
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class BkDBTablesVC: BKRestVC {
    
    var model : VisualizationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Data Set"
        self.titleField = "VIEW_NAME"
        limit = 5000
    }
    
    override func getSql() ->String?
    {
        return "select VIEW_NAME from all_views where owner='BLUEKAI'"
    }
    
    var waiting = false
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (waiting)
        {
            return;
        }
        waiting = true
        
        let columnsVC = BKDBColumnsVC(nibName: "BKDBColumnsVC", bundle: nil)
        let selected: NSDictionary? = values?.objectAtIndex(indexPath.row) as? NSDictionary
        
        if let dbName = selected?.objectForKey(self.titleField!) as? String
        {
            
            columnsVC.model = model;
            
            model?.tableName = dbName;
            
            columnsVC.tableName = (selected?.objectForKey(self.titleField!) as! String)
            
            columnsVC.refresh { (data, error) -> Void in
                if (error == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController!.pushViewController(columnsVC, animated: true )
                    })
                    
                }
                self.waiting = false
            }
        }

    }

}
