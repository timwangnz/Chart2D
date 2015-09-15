//
//  DroppableView.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class DroppableView: UIView, Droppable {
    func dropItem(item: UIView, dropInfo: [String : AnyObject]) {
        println("\(dropInfo)")
    }
}
