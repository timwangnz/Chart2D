//
//  SSCommentsVC.h
//  SixStreams
//
//  Created by Anping Wang on 3/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@interface SSCommentsVC : SSTableViewVC

@property (nonatomic) id itemCommented;
@property (nonatomic) NSString *itemType;
@property (nonatomic) BOOL oneAtATime;
@property (nonatomic) UITableView *layoutManager;

@end
