//
//  BKFrontPageVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/22/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKFrontPageVC.h"

@interface BKFrontPageVC ()
{
    NSDictionary *entity;
    NSDictionary *sections, *displayNames;
}

@end

@implementation BKFrontPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select ORACLE.*, STATS.* from BK_ORACLE_VIEW ORACLE, BK_PROFILE_STATS_VIEW STATS where ORACLE.CREATED_AT  between sysdate -1 and sysdate AND ORACLE.CREATED_AT = STATS.CREATED_AT";
    sections = @{
                   @"Profiles" : @[@"PROFILES", @"UPDATED_IN30DAYS", @"UPDATED_IN7DAYS", @"UPDATED_24HR"],
                 @"ID Types" : @[@"ANDROID_IDS", @"APPLE_AD_IDS", @"STATS_ID", @"VERIZON_UIDHS", @"GOOGLE_AD_IDS", @"DESKTOP_IDS", @"FIRST_PARTY_IDS"],
               
                 @"Operational" : @[@"OFFLINE_UPDATED", @"ID_SWAPPED",@"TOTAL_TAGGED",@"TAGGED_TODAY"]
                 };
    
    displayNames = @{
                  @"ANDROID_IDS":@"Android Ids",
                  @"APPLE_AD_IDS":@"Apple Ad Ids",
                  @"STATS_ID" : @"Stats Ids",
                  @"VERIZON_UIDHS" : @"Verizon UIDH",
                  @"GOOGLE_AD_IDS" : @"Google Ad Ids",
                  @"DESKTOP_IDS" : @"Desktop Ids",
                  @"FIRST_PARTY_IDS" : @"First Party Ids",
                  @"PROFILES" : @"Profiles",
                  @"UPDATED_IN30DAYS" : @"Updated in 30 Days",
                  @"UPDATED_IN7DAYS" : @"Updated in 7 Days",
                  @"UPDATED_24HR" : @"Updated in 24 Hr",
                  @"OFFLINE_UPDATED" : @"Total Offline Updates",
                  @"ID_SWAPPED" : @"Total Id Swaps",
                  @"TOTAL_TAGGED" : @"Total Tagged",
                  @"TAGGED_TODAY" : @"Tagged in 24 Hr."
                 };
    
    [self getData];
}

- (void) processServerData: (id)data
{
    dataReceived = data;
    NSArray *cats = data[@"data"];
    entity = cats[0];
    
    objects = [NSMutableArray array];
    for (id key in [entity allKeys]) {
        [objects addObject: key];
    }
    filteredObjects = [NSMutableArray  arrayWithArray:objects];
    [self updateModel];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections allKeys][section];
   
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [sections allKeys][section];
    return [sections[sectionName] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return  [sections count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    
    //NSString *key = filteredObjects[indexPath.row];
    NSString *sectionName = [sections allKeys][indexPath.section];
    
    id key = sections[sectionName][indexPath.row];
    
    cell.textLabel.text = displayNames[key];
    cell.detailTextLabel.text = [self formatValue:[entity objectForKey:key]];
    
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor blueColor];

    return cell;
}


@end
