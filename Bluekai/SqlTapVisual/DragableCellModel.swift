//
//  BkDragableCellModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

protocol DraggableCellDelegate{
    func swap(from:NSIndexPath,to:NSIndexPath)
}

class DragableCellModel: NSObject {
    
    var dataTableView : UITableView?
    var delegate : DraggableCellDelegate? = nil
    var model : VisualizationModel?
    
    func setup(tableview : UITableView, model : VisualizationModel)
    {
        tableview.separatorStyle = .None
        tableview.rowHeight = 50.0
        self.model = model;
        
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
    
    func subviewAt(point:CGPoint, inView: UIView) -> UIView? {
        var subviews = inView.subviews
        if (subviews.count == 0) { return nil}
        for subview in subviews {
            if (CGRectContainsPoint(subview.frame, point))
            {
                if (subview is Droppable)
                {
                    return subview as? UIView
                }
            }
        }
        return nil
    }
    
    func subviewFor(longPress : UILongPressGestureRecognizer, inView: UIView) -> UIView? {
        var point = longPress.locationInView(inView)
        var subviews = inView.subviews
        if (subviews.count == 0) { return nil}
        for subview in subviews {
            if (CGRectContainsPoint(subview.frame, point))
            {
                return subview as? UIView
            }
        }
        return nil
    }
    
    func findDroppable(longPress : UILongPressGestureRecognizer, inView:UIView) -> Droppable?
    {
        let nextview = subviewFor(longPress, inView: inView);
        if (nextview == nil)
        {
            return nil;
        }
        
        if (nextview is Droppable)
        {
            return nextview as? Droppable
        }
        else
        {
            return findDroppable(longPress, inView: nextview!)
        }
        
        
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        var locationInView = longPress.locationInView(dataTableView)
        var indexPath = dataTableView!.indexPathForRowAtPoint(locationInView)
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let rootview = appDelegate.window!
        
        var locationInWindow = longPress.locationInView(rootview)
        let hitView = findDroppable(longPress, inView: rootview)

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
            else
            {
                if (hitView != nil)
                {
                    let row = Path.initialIndexPath?.row
                    let section = Path.initialIndexPath?.section
                    if (section == 0)
                    {
                        let dim = self.model?.dataSource.dimensions[row!]
                        
                        hitView!.dropItem(self.dataTableView!, dropInfo: ["dimesion": dim!])
                    }
                    else
                    {
                        let messure = self.model?.dataSource.measures[row!]
                        hitView!.dropItem(self.dataTableView!, dropInfo: ["measure": messure!])
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
