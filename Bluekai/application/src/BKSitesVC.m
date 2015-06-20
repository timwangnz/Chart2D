//
//  SiteVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/9/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKSitesVC.h"
#import "BKCategoriesVC.h"

@interface BKSitesVC ()
{

}

@end

@implementation BKSitesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.partnerId)
    {
        self.sql = [NSString stringWithFormat: @"select site_id, site_name, sum(tagged) Tagged from bk_site_view where tagged != 0 and partner_id = %ld group by (site_id, site_name)", (long)self.partnerId ];
    }
    else
    {
        self.sql = @"select * from bk_site";
    }
    self.titleField = @"SITE_NAME";
    self.detailField = @"TAGGED";
    self.cellStyle = UITableViewCellStyleSubtitle;
    [self getData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id site = objects[indexPath.row];
    BKCategoriesVC *categoryVC = [[BKCategoriesVC alloc]init];
    categoryVC.parentId = 344;
    categoryVC.title = @"Inventory";
    categoryVC.siteId = [site[@"SITE_ID"] intValue];
    [self.navigationController pushViewController:categoryVC animated:YES];
}


@end
