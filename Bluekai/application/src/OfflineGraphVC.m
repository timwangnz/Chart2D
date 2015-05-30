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
    graphview.sql = [NSString stringWithFormat:@"select to_char(start_time, 'MM/DD HH24') TIME, sum(lookups) look_ups, sum(successes) successes, sum(not_found) not_found, sum(timeout_errors) timeouts from bk_offline_ingestion_view where start_time between sysdate - %d and sysdate group by start_time order by start_time", self.days == 0 ? 1 : self.days];
    graphview.limit = 164;
    graphview.title = self.title;
    graphview.valueFields[0] = @"LOOK_UPS";
    graphview.valueFields[1] = @"SUCCESSES";
    graphview.valueFields[2] = @"NOT_FOUND";
    graphview.valueFields[3] = @"TIMEOUTS";
    
    graphview.displayNames = @{
                               @"LOOK_UPS":@"Lookups Tried",
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
    graphview.xAxisStyle.tickStyle.majorTicks = 12;
    graphview.legendType = Graph2DLegendTop;
    graphview.autoScale = NO;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = [[Graph2DFillStyle alloc]init];
    graphview.fillStyle.color =[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.4];
    graphview.cacheTTL = 3600;
    [graphview reload];
}
@end
