//
//  StorageCommonVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKStorageCommonVC.h"
#import "HTTPConnector.h"
#import "BKStorageManager.h"

@interface BKStorageCommonVC ()<HTTPConnectorDelegate, UISearchBarDelegate>
{
    IBOutlet UIActivityIndicatorView *activityView;
}

@end

@implementation BKStorageCommonVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.cellStyle = UITableViewCellStyleDefault;
    formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumIntegerDigits = 13;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 8;
    formatter.usesSignificantDigits = NO;
    formatter.usesGroupingSeparator = YES;
    formatter.groupingSeparator = @",";
    formatter.decimalSeparator = @".";
    self.cacheTTL  = -1;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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
    tableview.hidden = NO;
    [tableview reloadData];
}

- (void) getData
{
    tableview.hidden = YES;
   
    if (![self checkCache])
    {
        [self.view addSubview:activityView];
        [activityView startAnimating];
        activityView.hidden = NO;

        HTTPConnector *conn = [[HTTPConnector alloc]init];
        conn.url = [NSString stringWithFormat: @"http://vulcan03.wdc.bluekai.com:8080/dataservice/api/v1/storage/query?limit=%d", self.limit <= 0 ? 5000 : self.limit ];
        NSDictionary *sql = @{@"sql":self.sql};
        conn.delegate = self;
        [conn post:sql withHeader:@{@"Content-Type":@"application/json",@"x-bk-cdss-client-key":@"7CSnR44TTH6IPfGJSLyTaw"}];
    }
}

- (void) invalidateCache
{
    [BKStorageManager invalidateCache:self.sql];
}

- (BOOL) checkCache
{
    id cached = [BKStorageManager checkCache:self.sql timeToLive: self.cacheTTL];
    if (cached)
    {
        [self processServerData:cached];
        return YES;
    }
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

- (void) processError:(NSError *) error
{
    if(!activityView.hidden)
    {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    [[[UIAlertView alloc]initWithTitle:@"Network Error"
                               message:@"Failed to get data, please try again later"
                              delegate:nil
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil, nil] show ];
}

- (void) didFinishLoading: (id)data
{
    if(!activityView.hidden)
    {
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    
    [BKStorageManager cacheData:data at:self.sql];
    [self processServerData:data];
}

- (void) processServerData: (id)data
{
    NSArray *cats = data[@"data"];
    objects = [NSMutableArray arrayWithArray:cats];
    filteredObjects = [NSMutableArray  arrayWithArray:cats];
    [self updateModel];
}

- (NSString *) formatValue:(id) value
{
    
    if ([value isKindOfClass:NSNumber.class])
    {
        return [formatter stringFromNumber: value];
    }
    else{
        return [NSString stringWithFormat:@"%@", value];
    }
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:self.cellStyle reuseIdentifier:@"simpelCell"];
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
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    return cell;
}

- (NSString *) today
{
   return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSString *) objectTitle : (id) object
{
    NSString *title = [NSString stringWithFormat:@"%@", object[self.titleField]];
    if ([title length] > 30)
    {
        NSString *tail = [title substringFromIndex:[title length]-20];
        NSString *header = [title substringToIndex:5];
        title = [NSString stringWithFormat:@"%@...%@", header, tail];
    }
    return title;
}

- (NSString *) objectDetail : (id) object
{
    return  [self formatValue:object[self.detailField]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    activityView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
}
@end
