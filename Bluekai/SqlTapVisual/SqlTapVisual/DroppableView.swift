//
//  DroppableView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class DroppableView: UIView, Droppable, DragableViewModelDelegate{
    
    var draggle  = DragableViewModel()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        draggle.setup(self)
        self.draggle.delegate = self
    }
    
    var measures = [Measure]()
    var dimensions = [Dimension]()
    var model : VisualizationModel?
    
    func accept(item: UIView, dropInfo: [String : AnyObject]) -> Bool
    {
        return false;
    }
    
    func dropItem(item: UIView, dropInfo: [String : AnyObject]) {
        
        if (!self.accept(item, dropInfo:dropInfo))
        {
            return;
        }
        
        model = dropInfo["model"] as? VisualizationModel
        
        if let measure = dropInfo["measure"] as? Measure
        {
            if !contains(measures, measure)
            {
                measures.append(measure)
                self.addSubview(createButton(measure.fieldName, backgroundColor:UIColor.grayColor()))
            }
        }
        
        if let dimension = dropInfo["dimension"] as? Dimension
        {
            if !contains(dimensions, dimension)
            {
                dimensions.append(dimension)
                self.addSubview(createButton(dimension.fieldName, backgroundColor:UIColor.brownColor()))
            }
        }
        self.itemDropped()
    }
    
    
    func createButton(titleString :String, backgroundColor:UIColor) -> UIButton{
        let button : UIButton = UIButton()
        button.frame = CGRectMake(2, 5, self.frame.size.width - 4, self.frame.size.height - 10)
        button.backgroundColor = backgroundColor
        button.setTitle(titleString, forState: UIControlState.Normal)
        button.titleLabel!.font =  UIFont.systemFontOfSize(12)
        button.layer.cornerRadius = 4.0
        button.clipsToBounds = true
        return button
    }
    
    
    func itemDropped()
    {
        
    }
    
    func drop(view : UIView, from: UIView, to:UIView)
    {
        view.removeFromSuperview()
        if (self.model != nil)
        {
            self.model!.colorMeasure = nil
            model = nil
        }
        dimensions.removeAll(keepCapacity: false)
        measures.removeAll(keepCapacity: false)
    }
}
