//
//  StorageCommonVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "StorageCommonVC.h"
#import "HTTPConnector.h"

@interface StorageCommonVC ()<HTTPConnectorDelegate>

@end

@implementation StorageCommonVC

- (void) getData
{
    HTTPConnector *conn = [[HTTPConnector alloc]init];
    conn.url = @"http://apocalypse01.wdc.bluekai.com:8080/DataStorageService/api/v1/select";
    NSDictionary *sql = @{@"sql":self.sql};
    conn.delegate = self;
    [conn post:sql withHeader:@{@"Content-Type":@"application/json"}];
}

- (void) didFinishLoading: (id)data
{
    NSLog(@"%@", data);
}

@end
