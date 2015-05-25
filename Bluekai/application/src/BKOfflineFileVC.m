//
//  BKOfflineFileVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/24/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKOfflineFileVC.h"

@interface BKOfflineFileVC ()

@end

@implementation BKOfflineFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
        self.cellStyle = UITableViewCellStyleSubtitle;
    self.sql = [NSString stringWithFormat: @"select filename, records, to_char(end_time, 'MM/DD') end_date from bk_offline_file where directory = '%@' and end_time between sysdate - 7 and sysdate order by end_time desc", self.partner];
    self.titleField = @"FILENAME";
    self.detailField = @"RECORDS";
    [self invalidateCache];
    self.limit = 5000;
    [self getData];
}

- (NSString *) objectDetail : (id) object
{
    NSString *details = [super objectDetail:object];
    details = [NSString stringWithFormat:@"%@ - %@ Records",
               object[@"END_DATE"],
               details];
    return details;
}


@end
