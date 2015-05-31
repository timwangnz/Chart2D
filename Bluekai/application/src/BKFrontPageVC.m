//
//  BKFrontPageVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/22/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKFrontPageVC.h"
#import "SqlGraphView.h"

@interface BKFrontPageVC ()
{
    NSIndexPath  *selectedIndexPath;
    IBOutlet SqlGraphView *trend;
}

@end

@implementation BKFrontPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select * from BK_ORACLE_VIEW where CREATED_AT between sysdate -1 and sysdate";
    sections = @{
                   @"Profiles" : @[@"PROFILES", @"UPDATED_24HR", @"UPDATED_IN7DAYS", @"UPDATED_IN30DAYS"],
                 @"ID Types" : @[@"ANDROID_IDS", @"APPLE_AD_IDS", @"STATS_ID", @"VERIZON_UIDHS", @"GOOGLE_AD_IDS", @"DESKTOP_IDS", @"FIRST_PARTY_IDS"],
               
                 @"Operational" : @[@"OFFLINE_UPDATED", @"ID_SWAPPED",@"TOTAL_TAGGED",@"TAGGED_TODAY"]
                 };
  
    self.cacheTTL = 3600;
    trend.sql = [NSString stringWithFormat:
                 @"select * from BK_ORACLE_VIEW where sysdate - created_At < 30 order by created_at"];
    
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
                  @"TOTAL_TAGGED" : @"Total Tags",
                  @"TAGGED_TODAY" : @"Tags Generated in 24 Hr."
                 };
    trend.topMargin = 20;
    trend.hidden = YES;
    trend.bottomMargin = 60;
    trend.leftMargin = 60;
    trend.topPadding = 0;
    trend.legendType = Graph2DLegendTop;
    trend.xAxisStyle.tickStyle.majorTicks = 8;
    trend.limit = 30;
    trend.cacheTTL = 3600;
    trend.autoScaleMode = Graph2DAutoScaleMax;
    trend.yMin = 0;
    trend.displayNames =displayNames;
    trend.xLabelField = @"CREATION_DATE";
    [self getData];
    [self updateLayout];
}

-(void) showTrend:(NSIndexPath *) indexPath
{
    selectedIndexPath = indexPath;
    NSString *section = [sections allKeys][indexPath.section];
    NSString *row = sections[section][indexPath.row];
    trend.title = displayNames[section];
    trend.valueFields[0] = row;
    [trend reload];
    [self updateLayout];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showTrend:indexPath];
}

- (void) updateLayout
{
    [UIView animateWithDuration:0.4 animations:^{
        int header = 62;
        int trendHeight = trend.hidden ? 0 : 250;
        
        trend.frame = CGRectMake(0, self.view.bounds.size.height - trendHeight, trend.frame.size.width, trendHeight);
        tableview.frame = CGRectMake(tableview.frame.origin.x,
                                     header,
                                     tableview.frame.size.width,
                                     self.view.bounds.size.height - trend.frame.size.height - header);
    }];
}
@end
