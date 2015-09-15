//
//  MasterViewController.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/5/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class TapChartVisualVC: ChartMainVC {
        
    var detailViewController: VisualViewVC? = nil
    var objects = [AnyObject]()


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          
            self.preferredContentSize = CGSize(width: 200.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? VisualViewVC
            self.detailViewController!.model = model
        }
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! VisualViewVC
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}

