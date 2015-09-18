//
//  FilterContainerView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/16/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class FilterContainerView: DroppableView {

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
        if (self.dimensions.count == 0)
        {
            self.model!.clearFilters()
            return;
        }
        let dimension = self.dimensions[0];
        self.model!.addFilter(dimension)
    }

}
