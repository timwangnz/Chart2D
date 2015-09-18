//
//  DragableViewModel.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

protocol DragableViewModelDelegate{
    func drop(view : UIView, from:UIView, to:UIView)
}

protocol Droppable {
    func dropItem(item : UIView, dropInfo: [String : AnyObject])
}

class DragableViewModel: NSObject {
    
    var parentView : UIView?
    var delegate : DragableViewModelDelegate? = nil
    
    func setup(parentView : UIView)
    {
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        parentView.addGestureRecognizer(longpress)
        self.parentView = parentView
    }
    
    func snapshopOfView(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let viewSnappshot : UIView = UIImageView(image: image)
        viewSnappshot.layer.masksToBounds = false
        viewSnappshot.layer.cornerRadius = 0.0
        viewSnappshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        viewSnappshot.layer.shadowRadius = 5.0
        viewSnappshot.layer.shadowOpacity = 0.4
        return viewSnappshot
    }
    
    struct My {
        static var snapshot : UIView? = nil
    }

    func subviewAt(point:CGPoint, inView: UIView) -> UIView? {
        let subviews = inView.subviews
        
        if (subviews.count == 0) { return nil}
        
        let theSubviews : Array = inView.subviews
        
        for subview in Array(theSubviews.reverse()) {
            if (CGRectContainsPoint(subview.frame, point))
            {
                return subview
            }
        }
        return nil
    }
    
    func subviewFor(longPress : UILongPressGestureRecognizer, inView: UIView) -> UIView? {
        return subviewAt(longPress.locationInView(inView), inView:inView)
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
    var childView : UIView? = nil
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        let locationInView = longPress.locationInView(parentView)
        
        if (childView == nil)
        {
            childView = subviewAt(locationInView, inView: parentView!)
        }
        
        if (childView == nil)
        {
            return
        }
        
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootview = appDelegate.window!
        let locationInWindow = longPress.locationInView(rootview)
        let hitView = subviewAt(locationInWindow, inView: rootview)
        
        
        switch state {
        case UIGestureRecognizerState.Began:
            My.snapshot = snapshopOfView(childView!)
            let center = locationInWindow
            My.snapshot!.center = center
            My.snapshot!.alpha = 0.0
            
            rootview.addSubview(My.snapshot!)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                My.snapshot!.center = center
                My.snapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                My.snapshot!.alpha = 0.98
                self.childView!.alpha = 0.5
                }, completion: { (finished) -> Void in
                    if finished {
                        // cell.alpha = 0.5
                        //cell.hidden = true
                    }
            })
            break
        case UIGestureRecognizerState.Changed:
            My.snapshot!.center = locationInWindow
            break
        case UIGestureRecognizerState.Ended:
            My.snapshot!.hidden = true
            
            self.childView!.alpha = 1
            
            if (self.delegate != nil)
            {
                self.delegate?.drop(self.childView!, from:self.parentView!,  to:hitView!)
            }
            /*
            if let droppable = findDroppable(longPress, inView: rootview)
            {
                droppable.dropItem(self.childView!, dropInfo: ["dimension": ""])
            }
            */
            self.childView = nil
            break
        default:
            break
        }
    }
}
