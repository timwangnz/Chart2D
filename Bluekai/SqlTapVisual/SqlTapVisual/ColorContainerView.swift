//
//  ColorContainerView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/14/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class ColorContainerView: DroppableView {
    
    override func accept(item: UIView, dropInfo: [String : AnyObject]) -> Bool
    {
        for subview in self.subviews
        {
            subview.removeFromSuperview()
        }
        self.measures.removeAll(keepCapacity: true)
        self.dimensions.removeAll(keepCapacity: true)
        return true
    }
    
    override func itemDropped()
    {
        if (self.measures.count == 0)
        {
            self.model!.colorMeasure = nil
            return;
        }
        let measure = self.measures[0];        
        self.model!.colorMeasure = measure
    }
}
