//
//  StorageCommonVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "StorageCommonVC.h"
#import "HTTPConnector.h"
#import "BKStorageManager.h"

@interface StorageCommonVC ()<HTTPConnectorDelegate, UISearchBarDelegate>
{
    NSDateFormatter *dateFormatter;
    NSMutableDictionary *sqlStmts;
}

@end

@implementation StorageCommonVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumIntegerDigits = 13;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 8;
    formatter.usesSignificantDigits = NO;
    formatter.usesGroupingSeparator = YES;
    formatter.groupingSeparator = @",";
    formatter.decimalSeparator = @".";
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDictionary *cachedStmts = [[BKStorageManager storageManager] read: @"sqlstmt.cache"];
    if (cachedStmts)
        sqlStmts = [NSMutableDictionary dictionaryWithDictionary: cachedStmts];
    else
        sqlStmts = [NSMutableDictionary dictionary];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0)
    {
        filteredObjects = [NSMutableArray array];
        for (id object in objects) {
            NSString *title = [self objectTitle:object];
            if ([[title uppercaseString] hasPrefix:[searchText uppercaseString]])
            {
                [filteredObjects addObject:object];
            }
        }
    }
    else{
        filteredObjects = [NSMutableArray arrayWithArray: objects];
    }
    [self updateModel];
}

- (void) updateModel
{
    [tableview reloadData];
}

- (void) getData
{
    if (![self checkCache])
    {
        HTTPConnector *conn = [[HTTPConnector alloc]init];
        conn.url = [NSString stringWithFormat: @"http://vulcan03.wdc.bluekai.com:8080/dataservice/api/v1/storage/query?limit=%d", self.limit <= 0 ? 5000 : self.limit ];
        NSDictionary *sql = @{@"sql":self.sql};
        [sqlStmts setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[sqlStmts count]] forKey:self.sql];
        conn.delegate = self;
        [conn post:sql withHeader:@{@"Content-Type":@"application/json",@"x-bk-cdss-client-key":@"7CSnR44TTH6IPfGJSLyTaw"}];
    }
}

- (BOOL) checkCache
{
    /*
    NSString *cachedKey = [sqlStmts objectForKey: self.sql];
    NSDictionary *cached = [[BKStorageManager storageManager] read: cachedKey];
    if (cached)
    {
        [self processServerData:cached[@"data"]];
        NSLog(@"Read from cache");
        return YES;
    }
     */
    return NO;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredObjects count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void) didFinishLoading: (id)data
{
    NSString *cachedKey = [sqlStmts objectForKey:self.sql];
    [[BKStorageManager storageManager] save:sqlStmts uri: @"sqlstmt.cache"];
    [[BKStorageManager storageManager] save:@{@"data":data, @"time":[NSDate date]} uri: cachedKey];
    [self processServerData:data];
}

- (void) processServerData: (id)data
{
    dataReceived = data;
    NSArray *cats = data[@"data"];
    objects = [NSMutableArray arrayWithArray:cats];
    filteredObjects = [NSMutableArray  arrayWithArray:cats];
    [self updateModel];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    
    id object = filteredObjects[indexPath.row];
    
    cell.textLabel.text = [self objectTitle:object];

    NSString *details = [self objectDetail:object];
    if(details)
    {
        cell.detailTextLabel.text = details;
    }
    else
    {
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (NSString *) today
{
   return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSString *) objectTitle : (id) object
{
    return [NSString stringWithFormat:@"%@", object[self.titleField]];
}

- (NSString *) objectDetail : (id) object
{
    return  [NSString stringWithFormat:@"%@", object[self.detailField]];
}

@end
