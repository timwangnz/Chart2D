//
//  ChartField.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/18/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class ChartField: NSObject {
    var fieldName : String
    var dataType:String
    var type : Int = 0
    
    init(fieldName: String, dateType: String, type:Int)
    {
        self.fieldName = fieldName
        self.dataType = dateType
        self.type = type
    }
}
