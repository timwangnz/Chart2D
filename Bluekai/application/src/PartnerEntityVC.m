//
//  PartnerEntityVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//
#import <Chart2D/Chart2D.h>
#import "PartnerEntityVC.h"
#import "SiteVC.h"
#import "CampaignWinsVC.h"
#import "SqlGraphView.h"

@interface PartnerEntityVC ()<Graph2DChartDelegate, Graph2DDataSource>
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

@implementation PartnerEntityVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    displayNames = @{
                     @"PARTNER_ID" : @"Partner Id",
                     @"PARTNER_NAME":@"Partner Name",
                     @"COMPANY_NAME" : @"Company Name",
                     @"OFFLINE_UPDATES":@"Total Offline Updates",
                     @"SWAPPED_IDS" : @"Total ID Swaps",
                     @"TOTAL_TAGGED" : @"Total Tags",
                     @"TAGGED_TODAY" : @"Tags Generated in 24 Hr"
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
    chartview.title = @"Inventory";
    chartview.valueFields[0] = @"TAGS";
    chartview.xLabelField = @"CREATED_AT";
    chartview.legendType = Graph2DLegendNone;    chartview.topMargin = 40;
    chartview.bottomMargin = 60;
    chartview.leftMargin = 60;
    chartview.topPadding = 0;
    chartview.cacheTTL = 3600;
    [chartview reload];
    
}

- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}

//number of items in a group
//return number of items
- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return 20;
}

//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) item forSeries :(NSInteger) series
{
    return [NSNumber numberWithFloat: 12 + 12.9*item];
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
    chartview.caption = [[Graph2DTextStyle alloc]initWithText:chartview.title ];
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
    
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.text = [self formatValue:[self.partner objectForKey:key]];
    return cell;
}

- (IBAction)showCFRStatus:(id)sender
{
    SiteVC *siteVC = [[SiteVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showOfflineUpdates:(id)sender
{
    SiteVC *siteVC = [[SiteVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showSites:(id)sender
{
    SiteVC *siteVC = [[SiteVC alloc]init];
    siteVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    siteVC.title = [NSString stringWithFormat:@"%@ Sites", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:siteVC animated:YES];
}

- (IBAction)showWins:(id)sender
{
    CampaignWinsVC *campaignVC = [[CampaignWinsVC alloc]init];
    campaignVC.partnerId = [self.partner[@"PARTNER_ID"] intValue];
    
    campaignVC.title = [NSString stringWithFormat:@"%@ Wins", self.partner[@"PARTNER_NAME"]];
    [self.navigationController pushViewController:campaignVC animated:YES];
}
@end
