//
//  SqlGraphVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/11/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "CFRGraphVC.h"
#import "SqlGraphView.h"


@interface CFRGraphVC ()
{
    IBOutlet SqlGraphView *graphview;
    IBOutlet SqlGraphView *tagged;
}

@end

@implementation CFRGraphVC

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
    graphview.xAxisStyle.tickStyle.majorTicks = 8;
    graphview.yAxisStyle.labelStyle.format = @"%.0f";
    graphview.yAxisStyle.labelStyle.offset = 10;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = [[Graph2DFillStyle alloc]init];
    graphview.fillStyle.color =[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.4];
    graphview.displayNames = @{
                               @"USERS_RUN":@"Profiles Run",
                               @"USERS_FOUND" : @"Profiles Found",
                               @"USERS_WASTED": @"Profiles Wasted"
                               };
    graphview.cacheTTL = 3600;
    [graphview reload];
    
    
    tagged.sql = [NSString stringWithFormat: @"select total_tags,total_won, to_char(start_time, 'MM/DD HH24') TIME from bk_cfr_view where start_time between sysdate-%d and sysdate order by start_time",
                  self.days == 0 ? 1 : self.days];
    tagged.limit = 164;
    tagged.title = self.title;
    tagged.valueFields[0] = @"TOTAL_TAGS";
    tagged.valueFields[1] = @"TOTAL_WON";
    tagged.xLabelField = @"TIME";
    tagged.topMargin = 20;
    //  tagged.yAxisStyle.labelStyle.format = @"%.0f";
    tagged.bottomMargin = 60;
    tagged.leftMargin = 50;
    tagged.topPadding = 10;
    tagged.yMin = 0;
    tagged.yMax = 2000000000;
    tagged.autoScale = NO;
    tagged.xAxisStyle.tickStyle.majorTicks = 8;
    tagged.yAxisStyle.labelStyle.offset = 10;
    tagged.chartType = Graph2DLineChart;
    tagged.fillStyle = [[Graph2DFillStyle alloc]init];
    tagged.fillStyle.color =[UIColor colorWithRed:0.7 green:0.2 blue:0.5 alpha:0.9];
    tagged.displayNames = @{
                            @"TOTAL_TAGS":@"Total Tags Generated",
                            @"TOTAL_WON" : @"Total Wins"
                            };
    tagged.cacheTTL = 3600;
    [tagged reload];
    
}

@end
