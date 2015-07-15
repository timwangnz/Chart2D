//
//  BKCacheManager.swift
//  Monitor
//
//  Created by Anping Wang on 6/22/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

import Foundation

class BKCacheManager
{
    let DATA_KEY = "data"
    var uriCache  = [String: AnyObject]()
    let URI_CACHE_FILE_NAME = "test"
    
    func getCache(uri : String, timeToLive ttl:Int) ->AnyObject?
    {
        initCache()
        if let cachedUriKey = uriCache[uri] as? String
        {
            if let cachedData = readCache(cachedUriKey) as? Dictionary<String, AnyObject>
            {
                if let data: AnyObject? = cachedData[DATA_KEY]
                {
                    return data
                }
            }
        }
        return nil
    }
    
    func initCache()
    {
        if (!uriCache.isEmpty)
        {
            if let cachedStmts: AnyObject = readCache(URI_CACHE_FILE_NAME)
            {
                uriCache = cachedStmts as! Dictionary;
            }
        } else
        {
            uriCache = [String: AnyObject]();
            saveCache(URI_CACHE_FILE_NAME, value: uriCache);
        }
    }
    
    func saveCache(uri : String, value: AnyObject) -> Void
    {
        let filePath = getFileURL(uri).path!
        NSKeyedArchiver.archiveRootObject(value, toFile: filePath)
    }
    
    func readCache(uri : String) -> AnyObject?
    {
        if let value: AnyObject = uriCache[uri]
        {
            let filePath = getFileURL(uri).path!
            let dict2: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)
            return dict2
        }
        return nil;
    }
    
    func getFileURL(fileName: String) -> NSURL {
        let manager = NSFileManager.defaultManager()
        let dirURL = manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: nil)
        return dirURL!.URLByAppendingPathComponent(fileName)
    }
    
    
    func invalidateCache(uri:String)
    {
        initCache()
        
    }

}
