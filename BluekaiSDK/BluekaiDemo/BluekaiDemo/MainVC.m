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
    commands = @{@"Runtime Monitoring" : @[@"DAL", @"SNV", @"WDC"],
                 @"Operational Matrics" : @[@"CFR Status", @"Offline File Ingestion", @"Offline Status"],
                 @"Profile Matrics" : @[@"Inventory", @"Campaign", @"ID Spaces"],
                 @"Mobile SDK" : @[@"Demo", @"SDK"],
                 @"Taxonomy" : @[@"Rules", @"Hints", @"Dags"],
                 @"Partner 360" : @[@"Partner", @"Wins", @"ID Swaps", @"File Ingestions"]
            };
    
    sortedKeys = @[@"Operational Matrics" ,@"Profile Matrics",@"Runtime Monitoring", @"Partner 360",  @"Taxonomy"];
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
        
    }
    NSString *title = [commands objectForKey:sortedKeys[section]][indexPath.row];
    cell.textLabel.text = title;
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
    
    if ([title isEqualToString:@"IDFA Demo"])
    {
        CfrStatusVC *campaignVC = [[CfrStatusVC alloc]init];
        campaignVC.extendedLayoutIncludesOpaqueBars =  NO;
        campaignVC.title = @"CFR Status";
        
        [self.navigationController pushViewController:campaignVC animated:YES];
    }
    if ([title isEqualToString:@"Partner"])
    {
        PartnerVC *partnerVC = [[PartnerVC alloc]init];
      
        
        partnerVC.title = @"Partners";
        
        [self.navigationController pushViewController:partnerVC animated:YES];
    }
}
@end
