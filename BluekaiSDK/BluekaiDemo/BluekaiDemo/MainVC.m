//
//  MainVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/24/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "MainVC.h"
#import "CategoryVC.h"
#import "CampaignVC.h"
#import "PartnerVC.h"
#import "BluekaiIDVC.h"
#import "CFRGraphVC.h"
#import "OfflineGraphVC.h"
#import "DeliveryGraphVC.h"

#import "CfrStatusVC.h"

@interface MainVC ()<UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary *commands;
    NSArray *sortedKeys;
}

@end

@implementation MainVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    commands = @{
                 @"Pixel Servers" : @[@"CFR", @"Offline", @"Delivery"],
        
                 @"Inventory" : @[@"Inventory"]
                 
                 ,@"Mobile SDK" : @[@"SDK Demo"]
            
                ,@"Partner 360" : @[@"Partner"]
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
        cell.textLabel.font = [UIFont systemFontOfSize:24];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [commands objectForKey:sortedKeys[indexPath.section]][indexPath.row];
    if ([title isEqualToString:@"Inventory"])
    {
        CategoryVC *categoryVC = [[CategoryVC alloc]init];
        categoryVC.extendedLayoutIncludesOpaqueBars =  NO;
        categoryVC.title = @"Categories";
        categoryVC.parentId = 344;
        categoryVC.siteId = -1;
        [self.navigationController pushViewController:categoryVC animated:YES];
    }
    if ([title isEqualToString:@"Campaign"])
    {
        CampaignVC *campaignVC = [[CampaignVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"Campaigns";
       
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    if ([title isEqualToString:@"CFR Status"])
    {
        CfrStatusVC *campaignVC = [[CfrStatusVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"CFR Status";
        
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    
    if ([title isEqualToString:@"SDK Demo"])
    {
        BluekaiIDVC *campaignVC = [[BluekaiIDVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"Mobile SDK Demo";
        
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    
    if ([title isEqualToString:@"CFR"])
    {
        CFRGraphVC *sqlGraphVC = [[CFRGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"CFR Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    if ([title isEqualToString:@"Offline"])
    {
        OfflineGraphVC *sqlGraphVC = [[OfflineGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"Offline Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    if ([title isEqualToString:@"Delivery"])
    {
        DeliveryGraphVC *sqlGraphVC = [[DeliveryGraphVC alloc]init];
        sqlGraphVC.extendedLayoutIncludesOpaqueBars =  NO;
        sqlGraphVC.title = @"Delivery Trend";
        
        [self.navigationController pushViewController:sqlGraphVC animated:YES];
    }
    
    if ([title isEqualToString:@"Partner"])
    {
        PartnerVC *partnerVC = [[PartnerVC alloc]init];
      
        
        partnerVC.title = @"Partners";
        
        [self.navigationController pushViewController:partnerVC animated:YES];
    }
}
@end
