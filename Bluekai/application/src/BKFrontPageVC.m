//
//  BKFrontPageVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/22/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKFrontPageVC.h"
#import "SqlGraphView.h"
#import "SqlPieChartView.h"

@interface BKFrontPageVC ()
{
    NSIndexPath  *selectedIndexPath;
    IBOutlet SqlGraphView *trend;
     IBOutlet SqlPieChartView *idTypePieChart;
    IBOutlet UIView *testView;
}
- (IBAction) closeChartView:(id) sender;
@end

@implementation BKFrontPageVC
- (IBAction) closeChartView:(id) sender
{
    trend.hidden = YES;
    [self updateLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select * from BK_ORACLE_VIEW where CREATED_AT between sysdate - 1 and sysdate";
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
                  @"TAGGED_TODAY" : @"Tags in 24 Hr.",
                  @"OTHERS" : @"Others"
                 };
    
    trend.topMargin = 20;
    trend.hidden = YES;
    trend.bottomMargin = 60;
    trend.leftMargin = 60;
    trend.topPadding = 0;
    trend.legendType = Graph2DLegendTop;
    trend.xAxisStyle.tickStyle.majorTicks = 8;
    trend.yAxisStyle.tickStyle.majorTicks = 11;
    trend.limit = 30;
    trend.cacheTTL = 3600;
    trend.autoScaleMode = Graph2DAutoScaleMax;
    trend.yMin = 0;
    trend.displayNames =displayNames;
    trend.xLabelField = @"CREATION_DATE";
    trend.gridStyle = [[Graph2DGridStyle alloc]init];
    trend.gridStyle.penWidth = 0.2;
    
    trend.gridStyle.lineType = LineStyleDash;
    
    idTypePieChart.sql = @"select APPLE_AD_IDS,STATS_ID,GOOGLE_AD_IDS,DESKTOP_IDS,VERIZON_UIDHS+ANDROID_IDS+FIRST_PARTY_IDS OTHERS from BK_ORACLE_VIEW where CREATED_AT between sysdate - 1 and sysdate ";
    
    idTypePieChart.valueFields = @[@"APPLE_AD_IDS", @"STATS_ID", @"GOOGLE_AD_IDS", @"DESKTOP_IDS", @"OTHERS"];
    
    idTypePieChart.displayNames = displayNames;
    idTypePieChart.fillStyle = nil;
    [self getData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [sections allKeys][indexPath.section];
    if ([sectionName isEqualToString:@"ID Types"])
    {
        return 240;
    }
    else{
        return 44;
    }
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
    
    NSString *sectionName = [sections allKeys][indexPath.section];
   
    if ([sectionName isEqualToString:@"ID Types"])
    {
        idTypePieChart.frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        [cell.contentView addSubview:idTypePieChart];
        [cell.contentView bringSubviewToFront:idTypePieChart];
    }
    else{
        id key = sections[sectionName][indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
        cell.detailTextLabel.textColor =  [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
        
        cell.textLabel.text = displayNames[key];
        cell.detailTextLabel.text = [self formatValue:[entity objectForKey:key]];
    }
    return cell;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [sections allKeys][section];
    if ([sectionName isEqualToString:@"ID Types"])
    {
        return 1;
    }
    else
    return [sections[sectionName] count];
}

-(void) showTrend:(NSIndexPath *) indexPath
{
    selectedIndexPath = indexPath;
    NSString *section = [sections allKeys][indexPath.section];
    trend.title = displayNames[section];
    trend.valueFields  = sections[section];
    [trend reload];
    [self updateLayout];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [sections allKeys][indexPath.section];
    if ([sectionName isEqualToString:@"ID Types"])
    {
        return;
    }
    [self showTrend:indexPath];
}

- (void) updateLayout
{
    [UIView animateWithDuration:0.4 animations:^{
        [self _updateLayout];
    }];
}

- (void) _updateLayout
{
    int header = 62;
    int trendHeight = trend.hidden ? 0 : self.view.bounds.size.height - header;
    trend.frame = CGRectMake(0, self.view.bounds.size.height - trendHeight, trend.frame.size.width, trendHeight);
    tableview.frame = CGRectMake(tableview.frame.origin.x,
                                 header,
                                 tableview.frame.size.width,
                                 self.view.bounds.size.height - trend.frame.size.height - header);
}

- (void) viewWillAppear:(BOOL)animated
{
    [self _updateLayout];
    [idTypePieChart reload];
}


@end
