//
//  BKFileIngestionVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/24/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKOfflineDirectoryVC.h"
#import "BKOfflineFileVC.h"

@interface BKOfflineDirectoryVC ()

@end

@implementation BKOfflineDirectoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellStyle = UITableViewCellStyleValue1;

    self.sql = @"select directory partner, sum(records) records, sum(file_size) file_size from bk_offline_file where end_time between sysdate - 7 and sysdate group by directory";
    self.titleField = @"PARTNER";
    self.detailField = @"RECORDS";
    [self invalidateCache];
    self.limit = 5000;
    
    [self getData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BKOfflineFileVC *entityVC = [[BKOfflineFileVC alloc]init];
    id row = filteredObjects[indexPath.row];
    entityVC.partner = row[@"PARTNER"];
    entityVC.title = row[@"PARTNER"];
    [self.navigationController pushViewController:entityVC animated:YES];
}

@end
