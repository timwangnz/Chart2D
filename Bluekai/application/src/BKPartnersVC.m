//
//  ParnterVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKPartnersVC.h"
#import "BKPartnerVC.h"

@interface BKPartnersVC ()
@end

@implementation BKPartnersVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select PARTNER_NAME, PARTNER_ID, COMPANY_NAME, tagged_today, total_tagged, offline_updates, swapped_ids from bk_partner_view where created_at between sysdate - 1 and sysdate order by partner_name";
    self.titleField = @"PARTNER_NAME";
    self.detailField = @"PARTNER_ID";
    self.cacheTTL = 3600*24;
    self.limit = 5000;
    [self getData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BKPartnerVC *entityVC = [[ BKPartnerVC alloc]init];
    id row = filteredObjects[indexPath.row];
    entityVC.partner = row;
    entityVC.title = row[@"PARTNER_NAME"];
    [self.navigationController pushViewController:entityVC animated:YES];
}

@end
