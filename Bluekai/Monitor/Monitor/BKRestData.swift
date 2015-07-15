//
//  BKRestUtil.swift
//  Monitor
//
//  Created by Anping Wang on 6/22/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import Foundation


class BKRestData{
    var sql : String = "select 1 from dual"
    var cacheTTL : Int?
    var limit : Int = 20
    
    var requestUri:String?
    
    let cacheManager = BKCacheManager()
    
    class func parseJSON(inputData: NSData) -> NSDictionary
    {
        var error: NSError?
        var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
        
        return jsonDict
    }
    
    
    func getData(urlPath:String, header: Dictionary<String, String>, data : NSString, callback: (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void) -> Void{
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
    
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
      
        request.HTTPMethod = "POST";
        let encodedData = data.dataUsingEncoding(NSUTF8StringEncoding);
        request.HTTPBody =  encodedData;
        
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: callback)
    }
    
    func get(callback: (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void) -> Bool
    {
        if checkCache()
        {
            return true;
        }
        
        let requestUri = "http://vulcan03.wdc.bluekai.com:8080/dataservice/api/v1/storage/query?limit=\(limit)"
        let jsonObject = ["sql" : sql];
        
        let jsonString = JSONStringify(jsonObject);
        
        let header = ["Content-Type":"application/json","x-bk-cdss-client-key":"7CSnR44TTH6IPfGJSLyTaw"]
        //println("SQL call \(jsonString)");
        getData(requestUri, header:header, data: jsonString){(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if (error == nil)
            {
                callback(response:response, data:data, error:error);
            }
        }
    
        return false;
    }
    
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    func checkCache() -> Bool
    {
        if let cached = getCache()
        {
            processServerData(cached);
            return true
        }
        return false
    }
    
    func processServerData(data : NSDictionary) -> Void
    {
        
    }
    
    func getCache() -> NSDictionary?
    {
        if let uri = requestUri
        {
        return cacheManager.getCache(uri, timeToLive: cacheTTL!) as? NSDictionary
        }
        return nil
    }
    
}
