//
//  MainVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/24/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKMainVC.h"
#import "BKCategoriesVC.h"
#import "BKCampaignsVC.h"
#import "BKPartnersVC.h"
#import "BKSDKDemoVC.h"
#import "BKCFRGraphVC.h"
#import "BKOfflineGraphVC.h"
#import "BKDeliveryGraphVC.h"
#import "BKFrontPageVC.h"
#import "BKOfflineDirectoryVC.h"

#import "BKCfrStatusVC.h"

@interface BKMainVC ()<UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary *commands;
    NSArray *sortedKeys;
}

@end

@implementation BKMainVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    commands = @{
                 @"Pixel Servers" : @[@"CFR", @"Offline Status", @"Delivery", @"Offline Ingestion"],
        
                 @"Inventory" : @[@"Inventory"]
                 
                 ,@"Mobile SDK" : @[@"SDK Demo"]
            
                ,@"Partner 360" : @[@"Bluekai", @"Partner"]
            };
    
    sortedKeys = @[
                   @"Partner 360",
                   @"Inventory",
                   @"Mobile SDK",
                   @"Pixel Servers"
                   ];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[commands objectForKey:sortedKeys[section]] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sortedKeys count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sortedKeys[section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.indentationLevel = 0;
        
    }
    NSString *title = [commands objectForKey:sortedKeys[section]][indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [commands objectForKey:sortedKeys[indexPath.section]][indexPath.row];
    if ([title isEqualToString:@"Inventory"])
    {
        BKCategoriesVC *categoryVC = [[BKCategoriesVC alloc]init];
        categoryVC.extendedLayoutIncludesOpaqueBars =  NO;
        categoryVC.title = @"Categories";
        categoryVC.parentId = 344;
        categoryVC.siteId = -1;
        [self.navigationController pushViewController:categoryVC animated:YES];
    }
    if ([title isEqualToString:@"Campaign"])
    {
        BKCampaignsVC *campaignVC = [[BKCampaignsVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"Campaigns";
       
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    
    if ([title isEqualToString:@"Bluekai"])
    {
        BKFrontPageVC *frontPage = [[BKFrontPageVC alloc]init];
        frontPage.extendedLayoutIncludesOpaqueBars =  NO;
        frontPage.title = @"Overview";
        
        [self.navigationController pushViewController:frontPage animated:YES];
    }
    
    if ([title isEqualToString:@"CFR Status"])
    {
        BKCfrStatusVC *campaignVC = [[BKCfrStatusVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"CFR Status";
        
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    
    if ([title isEqualToString:@"SDK Demo"])
    {
        BKSDKDemoVC *campaignVC = [[BKSDKDemoVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"Mobile SDK Demo";
        
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    
    if ([title isEqualToString:@"CFR"])
    {
        BKCFRGraphVC *sqlGraphVC = [[BKCFRGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"CFR Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    
    if ([title isEqualToString:@"Offline Status"])
    {
        BKOfflineGraphVC *sqlGraphVC = [[BKOfflineGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"Offline Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    
    if ([title isEqualToString:@"Offline Ingestion"])
    {
        BKOfflineDirectoryVC *sqlGraphVC = [[BKOfflineDirectoryVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"File Ingestion";
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    
    
    if ([title isEqualToString:@"Delivery"])
    {
        BKDeliveryGraphVC *sqlGraphVC = [[BKDeliveryGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"Delivery Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    
    if ([title isEqualToString:@"Partner"])
    {
        BKPartnersVC *partnerVC = [[BKPartnersVC alloc]init];
      
        
        partnerVC.title = @"Partners";
        
        [self.navigationController pushViewController:partnerVC animated:YES];
    }
}
@end
