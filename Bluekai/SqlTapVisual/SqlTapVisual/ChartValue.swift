//
//  ChartValue.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 7/19/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

class ChartValue: NSObject {
    var fieldName : String
    var value:Double

    init(fieldName:String, value:Double)
    {
        self.value = value;
        self.fieldName = fieldName;
    }
}
