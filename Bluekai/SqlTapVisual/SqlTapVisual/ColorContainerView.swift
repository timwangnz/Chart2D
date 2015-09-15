//
//  ColorContainerView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/14/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class ColorContainerView: DroppableView {
    
    var chartFields = [ChartField]()
    
    override func dropItem(item: UIView, dropInfo: [String : AnyObject]) {
        if let measure = dropInfo["measure"] as? Measure
        {
            if !contains(chartFields, measure)
            {
                chartFields.append(measure)
                let button : UIButton = UIButton()
                button.frame = CGRectMake(2, 5, self.frame.size.width - 4, self.frame.size.height - 10)
                button.backgroundColor = UIColor.grayColor()
                button.setTitle(measure.fieldName, forState: UIControlState.Normal)
                self.addSubview(button)
            }
        }
    }
}
