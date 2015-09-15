//
//  Filter.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/12/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

enum FilterType : Int {
    case Include
    case Exclude
}

class Filter: NSObject {
    
    var type : FilterType = .Exclude
    
    var from : AnyObject?
    var to : AnyObject?
    
    init (from : AnyObject?, to:AnyObject?)
    {
        self.from = from
        self.to = to
    }
    
    func test(testValue : AnyObject?) -> Bool
    {
        return true;
    }
}
