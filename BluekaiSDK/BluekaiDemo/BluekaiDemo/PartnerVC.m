//
//  ParnterVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "PartnerVC.h"
#import "PartnerEntityVC.h"

@interface PartnerVC ()
@end

@implementation PartnerVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select PARTNER_NAME, PARTNER_ID,  COMPANY_NAME from bk_partner order by partner_name";
    self.titleField = @"PARTNER_NAME";
    self.detailField = @"PARTNER_ID";
    self.limit = 5000;
    [self getData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PartnerEntityVC *entityVC = [[ PartnerEntityVC alloc]init];
    id row = filteredObjects[indexPath.row];
    entityVC.partner = row;
    entityVC.title = row[@"PARTNER_NAME"];
    [self.navigationController pushViewController:entityVC animated:YES];
    
}

@end
