//
//  SSFredCommonVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCommonVC.h"

#define fredKey @"ef673da26430e206a8b7d3ce658b7162"

@interface SSFredCommonVC : SSCommonVC<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tvCategory;
    NSString *selectedKey;
    NSArray *sortedKeys;
}


@property (nonatomic, retain) NSDictionary *data;

- (NSString *) getUrl:(NSString *) catId;

- (void) reloadData:(id) catId;

- (NSString *) cellText: (id) item forKey :(NSString *) key;

@end
