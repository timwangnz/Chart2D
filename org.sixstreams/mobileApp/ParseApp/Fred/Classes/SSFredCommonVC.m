//
//  SSFredCommonVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredCommonVC.h"
#import "HTTPConnector.h"
@interface SSFredCommonVC ()<HTTPConnectorDelegate>

@end

@implementation SSFredCommonVC

- (void) setData:(NSDictionary *)data
{
    _data = data;
    
    sortedKeys = [[data allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [a compare:b];
    }];
    
}

- (NSString *)cellText:(id) item forKey:(NSString *)key
{
    return key;
}


- (NSString *) getUrl:(NSString *)catId
{
    return nil;
}

- (void) didFinishLoading: (NSData *)data
{
    //overridden to push stack
}

- (void) processData: (NSData *)data
{
    
}

- (void) processResponse: (NSURLResponse *)response
{
    
}

- (void) processError: (NSString *) error
{
    DebugLog(@"%@", error);
    [self showAlert:@"Network connection failed, try again later please" withTitle:@"Error"];
}

-(void) reloadData:(id) catId
{
    if(!catId)
    {
        return;
    }
    
    HTTPConnector *conn = [[HTTPConnector alloc]init];
    conn.url = [self getUrl:catId];
    //DebugLog(@"%@", conn.url);
    conn.delegate = self;
    [conn get];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tvCategory reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

#define CELL @"cell"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    NSString *key = [sortedKeys objectAtIndex:indexPath.row];
    cell.textLabel.text = [self cellText: [self.data objectForKey:key] forKey:key];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedKey = [sortedKeys objectAtIndex:indexPath.row];
    id selectedCategoryId = [self.data objectForKey:selectedKey];
    [self reloadData:selectedCategoryId];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


@end
