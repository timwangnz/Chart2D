//
//  BkDragableCellModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

protocol DraggableDelegate{
    
    func swap(from:NSIndexPath,to:NSIndexPath)

}

class DragableCellModel: NSObject {
    
    var dataTableView : UITableView?
    var delegate : DraggableDelegate? = nil
    
    func setup(tableview : UITableView)
    {
        tableview.separatorStyle = .None
        tableview.rowHeight = 50.0
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        tableview.addGestureRecognizer(longpress)
        dataTableView = tableview
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
        
    }
    
    struct My {
        static var cellSnapshot : UIView? = nil
    }
    struct Path {
        static var initialIndexPath : NSIndexPath? = nil
    }
    
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        var locationInView = longPress.locationInView(dataTableView)
        var indexPath = dataTableView!.indexPathForRowAtPoint(locationInView)
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let rootview = appDelegate.window!
        
        var locationInWindow = longPress.locationInView(rootview)
        
        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = dataTableView!.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot = snapshopOfCell(cell)
                
                var center = locationInWindow
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                
                rootview.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    //center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.5
                    }, completion: { (finished) -> Void in
                        if finished {
                            // cell.alpha = 0.5
                            //cell.hidden = true
                        }
                })
            }
            
        case UIGestureRecognizerState.Changed:
            //var center = My.cellSnapshot!.center
            //center.y = locationInView.y
            My.cellSnapshot!.center = locationInWindow
            
        case UIGestureRecognizerState.Ended:
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                if (indexPath!.section != Path.initialIndexPath!.section)
                {
                    if ((self.delegate) != nil)
                    {
                        self.delegate?.swap(indexPath!, to: Path.initialIndexPath!)
                    }
                }
            }
            dataTableView!.reloadData();
            My.cellSnapshot!.hidden = true
            break;
        default:
            break;
        }
        
    }
    
}
