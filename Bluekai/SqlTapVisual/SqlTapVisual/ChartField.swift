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
    
    override func isEqual(object: AnyObject?) -> Bool {
        if !(object is ChartField)
        {
            return false
        }
        let chartField = object as! ChartField
        return self.fieldName == chartField.fieldName
    }
    
    static var dataFormats = [String : NSDateFormatter]()
    
    class func getDateFormatter(dateformat : String) -> NSDateFormatter
    {
        if let formatter = dataFormats[dateformat]
        {
            return formatter
        }
        else
        {
            let newFormatter = NSDateFormatter()
            newFormatter.dateFormat = dateformat
            dataFormats.updateValue(newFormatter, forKey: dateformat)
            return newFormatter
        }
    }
    
    class func toDate(stringValue : String, format: String) -> NSDate
    {
        return getDateFormatter(format).dateFromString(stringValue)!
    }
    
    func formatObject(object : AnyObject?) -> String
    {
        if (object == nil)
        {
            return ""
        }
        
        if (object is NSDate)
        {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            return formatter.stringFromDate(object as! NSDate)
        }
        if (object is Double)
        {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            return numberFormatter.stringFromNumber(object as! Double)!
        }
        else
        {
            return "\(object as! String)"
        }
    }
}
