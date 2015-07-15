//
//  BKInventoryVC.swift
//  Monitor
//
//  Created by Anping Wang on 6/22/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit
import Chart2D

class BKInventoryVC: BKRestVC {
    var selectedCategory = 0
    
    @IBOutlet var trendView: BKSqlChartView!
    var parentId : Int?=344
    var siteId : Int? = -1
    
    let types = ["Public", "Private"]
    
    override func viewDidLoad() {
        self.title = "Inventory"
        self.titleField = "CATEGORY_NAME"
        limit = 5000
    }
    
    override func getSql() ->String?
    {
        var sql = ""
        if (siteId == -1)
        {
            sql = "select cat.category_name, inv.INVENTORY, inv.ab_tested,  created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id(+)=-1 and cat.parent_id=\(parentId!) and cat.category_id = inv.category_id(+) and to_char(created_at(+), 'DD-MM-YYYY') = '\(today())' order by cat.category_name"
        }
        else if (parentId == 344)
        {
            sql = "select cat.parent_id, cat.depth, cat.category_name, inv.inventory, inv.ab_tested, created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id = \(siteId!) and cat.category_id(+) = inv.category_id and to_char(created_at(+), 'DD-MM-YYYY') = '\(today())' and cat.depth in (select min(cat.depth) from bk_inventory_view inv, bk_category cat where inv.site_id = \(siteId!) and cat.category_id(+) = inv.category_id and to_char(created_at(+), 'DD-MM-YYYY') = '\(today())') order by cat.category_name"
        }
        else
        {
            sql = "select cat.category_name, inv.inventory, inv.ab_tested, created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id=\(siteId) and cat.parent_id=%d and cat.category_id = inv.category_id(+) and to_char(created_at(+), 'DD-MM-YYYY') = '\(today())' order by cat.category_name"
        }
        return sql
    }
    
    func updateLayout() -> Void
    {
        let header = CGFloat(0.0);
        var height = self.view.bounds.size.height / 3;
        if selectedCategory == 0
        {
            height = 0;
        }
        
        trendView.frame = CGRectMake(trendView.frame.origin.x, self.view.bounds.size.height - height, trendView.frame.size.width, height);
        
        if (selectedCategory == 344) {
            dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, header, dataTableView.frame.size.width, self.view.bounds.size.height - header);
        }
        else{
            dataTableView.frame = CGRectMake(dataTableView.frame.origin.x, header, dataTableView.frame.size.width, self.view.bounds.size.height - dataTableView.frame.size.height - header);
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selected: NSDictionary? = values?.objectAtIndex(indexPath.row) as? NSDictionary
        
        let categoryId = (selected?.objectForKey("CATEGORY_ID") as! NSNumber).integerValue;
        
        if (categoryId == selectedCategory)
        {
            let isLeaf = selected?.objectForKey("IS_LEAF") as! NSString
            
            if (isLeaf == "1") {
                return;
            }
            
            let categoryVC = BKInventoryVC(nibName: "BKInventoryVC", bundle: nil)
            
            categoryVC.parentId = categoryId;
            categoryVC.title = (selected?.objectForKey("CATEGORY_NAME") as! String);
            categoryVC.siteId = self.siteId;
            
            categoryVC.refresh { (data, error) -> Void in
                if (error == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController!.pushViewController(categoryVC, animated: true)
                    })
                }
            }
            
        }
        else{
          selectedCategory = categoryId
          showTrend(categoryId)
        }
    }
    
    func showTrend(categoryId:Int) -> Void
    {
    
        trendView.sql = "select to_char(created_at, 'MM/DD') CREATED_AT, AB_TESTED, INVENTORY from bk_inventory_view where category_id = \(categoryId) and site_id = \(siteId!) and sysdate - created_at < 30 order by created_at"
        
        
        selectedCategory = categoryId;
        trendView.limit = 30;
        trendView.title = "Inventory"
        trendView.valueFields = ["INVENTORY","AB_TESTED"]
        trendView.xLabelField = "CREATED_AT"
        trendView.topMargin = 20
        trendView.bottomMargin = 40
        trendView.leftMargin = 60
        trendView.topPadding = 0
        
        trendView.yMin = 0
        trendView.autoScaleMode = Graph2DAutoScaleMax
        trendView.xAxisStyle.tickStyle.majorTicks = 8
        trendView.yAxisStyle.tickStyle.majorTicks = 6
        trendView.displayNames = ["INVENTORY":"Tagged in 30 Days", "AB_TESTED":"AB Tested 30 Days"]
        trendView.legendType = Graph2DLegendTop
        //showAll = NO;
        trendView.cacheTTL = 3600;
        self.titleField = "CATEGORY_NAME"
        if (categoryId == 344)
        {
            trendView.hidden = true
        }
        else
        {
            trendView.reload({(data, error)->Void in
                    self.updateModel()
                })
        }
    }

}
