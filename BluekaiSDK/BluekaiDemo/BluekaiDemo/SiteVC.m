//
//  SiteVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/9/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "SiteVC.h"
#import "CategoryVC.h"

@interface SiteVC ()
{

}

@end

@implementation SiteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.partnerId)
    {
        self.sql = [NSString stringWithFormat: @"select * from bk_site where partner_id = %ld", (long)self.partnerId ];
    }
    else
    {
        self.sql = @"select * from bk_site";
    }
    self.titleField = @"SITE_NAME";
    self.detailField = @"SITE_ID";
    [self getData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id site = objects[indexPath.row];
    CategoryVC *categoryVC = [[CategoryVC alloc]init];
    categoryVC.parentId = 344;
    categoryVC.title = @"Inventory";
    categoryVC.siteId = [site[@"SITE_ID"] intValue];
    [self.navigationController pushViewController:categoryVC animated:YES];
}


@end
