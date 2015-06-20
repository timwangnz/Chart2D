//
//  SqlGraphVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/11/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKCFRGraphVC.h"
#import "SqlGraphView.h"


@interface BKCFRGraphVC ()
{
    IBOutlet SqlGraphView *graphview;
    IBOutlet SqlGraphView *tagged;
}

@end

@implementation BKCFRGraphVC

- (void)updateChart
{
    
    graphview.sql = [NSString stringWithFormat: @"select users_run, users_found, users_wasted, to_char(start_time, 'MM/DD HH24') TIME from bk_cfr_view where start_time between sysdate - %d and sysdate order by start_time",
                     self.days == 0 ? 1 : self.days];
    
    
    graphview.limit = 164;
    graphview.title = self.title;
    graphview.valueFields[0] = @"USERS_RUN";
    graphview.valueFields[1] = @"USERS_FOUND";
    graphview.valueFields[2] = @"USERS_WASTED";
    graphview.xLabelField = @"TIME";
    graphview.topMargin = 20;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 50;
    graphview.topPadding = 10;
    graphview.yMin = 0;
    graphview.autoScaleMode = Graph2DAutoScaleMax;
    graphview.xAxisStyle.tickStyle.majorTicks = 8;
    graphview.yAxisStyle.labelStyle.format = @"%.0f";
    graphview.yAxisStyle.labelStyle.offset = 10;
    graphview.yAxisStyle.tickStyle.majorTicks = 6;
    graphview.displayNames = @{
                               @"USERS_RUN":@"Profiles Run",
                               @"USERS_FOUND" : @"Profiles Found",
                               @"USERS_WASTED": @"Profiles Wasted"
                               };
    graphview.cacheTTL = 3600;
    [graphview reload];
    
    tagged.sql = [NSString stringWithFormat: @"select total_tags, total_won, to_char(start_time, 'MM/DD HH24') TIME from bk_cfr_view where start_time between sysdate-%d and sysdate order by start_time",
                  self.days == 0 ? 1 : self.days];
    tagged.limit = 164;
    tagged.title = self.title;
    tagged.valueFields[0] = @"TOTAL_TAGS";
    tagged.valueFields[1] = @"TOTAL_WON";
    tagged.xLabelField = @"TIME";
    tagged.topMargin = 20;
    tagged.yAxisStyle.tickStyle.majorTicks = 6;
    tagged.touchEnabled = YES;
    tagged.valueFormat = @"%.0f";
    tagged.bottomMargin = 60;
    tagged.leftMargin = 50;
    tagged.topPadding = 10;
    tagged.yMin = 0;
    tagged.yMax = 2000000000;
    tagged.autoScaleMode = Graph2DAutoScaleMax;
    tagged.xAxisStyle.tickStyle.majorTicks = 8;
    tagged.yAxisStyle.labelStyle.offset = 10;
    tagged.chartType = Graph2DLineChart;
    
    tagged.displayNames = @{
                            @"TOTAL_TAGS":@"Total Tags Generated",
                            @"TOTAL_WON" : @"Total Wins"
                            };
    tagged.cacheTTL = 3600;
    [tagged reload];
    
}

@end
