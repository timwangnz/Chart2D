//
//  OfflineGraphVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/20/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "OfflineGraphVC.h"
#import "SqlGraphView.h"

@interface OfflineGraphVC ()
{
    IBOutlet SqlGraphView *graphview;
}

@end

@implementation OfflineGraphVC


- (void) updateChart
{
    if (self.days == 1)
    {
        graphview.sql = [NSString stringWithFormat:@"select to_char(start_time, 'MM/DD HH24') TIME, LOOKUPS, successes, not_found, timeout_errors timeouts from BK_OFFLINE_HOURLY_VIEW where start_time between sysdate - %d and sysdate order by start_time", self.days == 0 ? 1 : self.days];
        graphview.xAxisStyle.tickStyle.majorTicks = 12;
    }
    else
    {
        graphview.sql = [NSString stringWithFormat:@"select to_char(start_time, 'MM/DD') TIME, LOOKUPS, successes, not_found, timeout_errors timeouts from BK_OFFLINE_DAILY_VIEW where start_time between sysdate - %d and sysdate order by start_time", self.days == 0 ? 1 : self.days];
        graphview.xAxisStyle.tickStyle.majorTicks = self.days;
    }
    
    
    graphview.limit = 164;
    graphview.title = self.title;
    graphview.valueFields[0] = @"LOOKUPS";
    graphview.valueFields[1] = @"SUCCESSES";
    graphview.valueFields[2] = @"NOT_FOUND";
    graphview.valueFields[3] = @"TIMEOUTS";
    
    graphview.displayNames = @{
                               @"LOOKUPS":@"Lookups Tried",
                               @"SUCCESSES" : @"Profiles Found",
                               @"NOT_FOUND": @"Profiles Not Found",
                               @"TIMEOUTS": @"Timeouts"
                               };
    
    graphview.xLabelField = @"TIME";
    graphview.topMargin = 20;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 50;
    graphview.topPadding = 10;
    graphview.yMin = 0;
    graphview.yMax = 10000000000;
    
    graphview.legendType = Graph2DLegendTop;
    graphview.autoScaleMode = Graph2DAutoScaleMax;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = nil;//[[Graph2DFillStyle alloc]init];
   // graphview.fillStyle.color =[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.4];
    graphview.cacheTTL = 3600;
    [graphview reload];
}
@end
