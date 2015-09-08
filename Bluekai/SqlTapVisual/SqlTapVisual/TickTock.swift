//
//  TickTock.swift
//  SqlTapVisual
//
//  Created by Anping Wang on 9/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import UIKit

var ticktock = TickTock()

class TickTock: NSObject {
    var startTime = NSDate()
    var context = ""
    
    func TICK(context :String){
        self.context = context
        startTime =  NSDate()
    }
    
    func TOCK(function: String = __FUNCTION__, file: String = __FILE__, line: Int = __LINE__)
    {
        println("\(function) \(context) Time: \(-startTime.timeIntervalSinceNow)\nLine:\(line) File: \(file)")
    }
}
