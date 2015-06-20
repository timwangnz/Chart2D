//
//  PartnerEntityVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//
#import <Chart2D/Chart2D.h>
#import "BKPartnerVC.h"
#import "BKSitesVC.h"
#import "BKCampaignWinsVC.h"
#import "SqlGraphView.h"

@interface BKPartnerVC ()
{
    IBOutlet SqlGraphView *chartview;
    NSDictionary *displayNames;
      NSArray *keys;
}

- (IBAction)showOfflineUpdates: (id)sender;
- (IBAction)showCFRStatus: (id)sender;

- (IBAction)showSites:(id)sender;
- (IBAction)showWins:(id)sender;
@end

@implementation BKPartnerVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    displayNames = @{
                     @"PARTNER_ID" : @"Partner Id",
                     @"TAGS" : @"Total Tags",
                     @"PARTNER_NAME":@"Partner Name",
                     @"COMPANY_NAME" : @"Company Name",
                     @"OFFLINE_UPDATES":@"Total Offline Updates",
                     @"SWAPPED_IDS" : @"Total ID Swaps",
                     @"TOTAL_TAGGED" : @"Total Tags",
                     @"TAGGED_TODAY" : @"Tags in 24 Hr"
                     };
    
    keys = @[@"PARTNER_ID",
            @"PARTNER_NAME",
            @"COMPANY_NAME",
            @"OFFLINE_UPDATES",
            @"SWAPPED_IDS",
            @"TOTAL_TAGGED",
            @"TAGGED_TODAY"];
    
    NSString *sql = @"select to_char(created_at, 'MM-DD-YYYY') CREATED_AT, total_tagged tags, offline_updates, swapped_ids, tagged_today from bk_partner_view where partner_id = %@ and sysdate - created_at < 14 order by created_at";
    
    chartview.sql = [NSString stringWithFormat:sql, self.partner[@"PARTNER_ID"]];
   
    chartview.limit = 20;
    chartview.title = @"Total Tags Over Time";
    chartview.valueFields[0] = @"TAGS";
    chartview.xLabelField = @"CREATED_AT";
    chartview.legendType = Graph2DLegendNone;
    chartview.autoScaleMode = Graph2DAutoScaleMax;
    chartview.yAxisStyle.tickStyle.majorTicks = 6;
    chartview.yMin = 0;
    chartview.topMargin = 40;
    chartview.bottomMargin = 60;
    chartview.leftMargin = 60;
    chartview.topPadding = 0;
    chartview.touchEnabled = YES;
    chartview.legendType = Graph2DLegendTop;
    chartview.displayNames = displayNames;
    chartview.cacheTTL = 3600;
    chartview.caption = [[Graph2DTextStyle alloc]initWithText:chartview.title];
    [chartview reload];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [keys count];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id key =  keys[indexPath.row];
    
     if ([key isEqualToString:@"SWAPPED_IDS"])
     {
         chartview.title = @"Ids Swapped Over Time";
         chartview.valueFields[0] = @"SWAPPED_IDS";
         

     }
    if ([key isEqualToString:@"TOTAL_TAGGED"])
    {
        chartview.title = @"Total Tags Over Time";
        chartview.valueFields[0] = @"TAGS";
       
        
    }
    if ([key isEqualToString:@"OFFLINE_UPDATES"])
    {
        chartview.title = @"Offline Updates Over Time";
        chartview.valueFields[0] = @"OFFLINE_UPDATES";
        
        
    }
    if ([key isEqualToString:@"TAGGED_TODAY"])
    {
        chartview.title = @"Daily Tags Over Time";
        chartview.valueFields[0] = @"TAGGED_TODAY";
       
        
    }
    chartview.caption = [[Graph2DTextStyle alloc]initWithText:chartview.title];
    
    [chartview reload];

}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  nil;
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
    
    id key =  keys[indexPath.row];
    
    cell.textLabel.text = displayNames[key];
    cell.detailTextLabel.text = [self formatValue:[self.partner objectForKey:key]];
    
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
    
    return cell;
}

- (IBAction)showCFRStatus:(id)sender
{
    BKSitesVC *siteVC = [[BKSitesVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showOfflineUpdates:(id)sender
{
    BKSitesVC *siteVC = [[BKSitesVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showSites:(id)sender
{
    BKSitesVC *siteVC = [[BKSitesVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showWins:(id)sender
{
    BKCampaignWinsVC *campaignVC = [[BKCampaignWinsVC alloc]init];
    campaignVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    
    campaignVC.title = [NSString stringWithFormat:@"%@ Wins", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:campaignVC animated:YES];
}

@end
