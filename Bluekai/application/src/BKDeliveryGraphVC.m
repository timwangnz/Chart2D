//
//  DeliveryGraphVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/21/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKDeliveryGraphVC.h"
#import "SqlGraphView.h"

@interface BKDeliveryGraphVC ()
{
    IBOutlet SqlGraphView *graphview;
}

@end

@implementation BKDeliveryGraphVC

- (void)updateChart {
    
    graphview.sql = [NSString stringWithFormat: @"select to_char(start_time, 'MM/DD HH24:MI') TIME, sum(targeted) targeted, sum(PREVWIN) PREVWIN, sum(LOSS_SDTUSER) SDT_USER, sum(LOSS_PUBLISHER) PUBLISHER, sum(won) won from bk_delivery_view where start_time between sysdate - %d and sysdate group by start_time order by start_time", self.days == 0 ? 1 : self.days];
    
    /*
    graphview.sql = [NSString stringWithFormat: @"select to_char(start_time, 'MM/DD HH24:MI') TIME,  targeted, LOSS_RECENCY, LOSS_BUYER_ONLY BUYER_ONLY, won from bk_delivery_mview where start_time between sysdate - %d and sysdate order by start_time", self.days == 0 ? 1 : self.days];
*/
    graphview.limit = 166;
    graphview.title = self.title;
    graphview.valueFields[0] = @"TARGETED";
    graphview.valueFields[1] = @"WON";
    graphview.valueFields[2] = @"PREVWIN";
    graphview.valueFields[3] = @"SDT_USER";
    graphview.valueFields[4] = @"PUBLISHER";
    graphview.xLabelField = @"TIME";
    
    graphview.topMargin = 25;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 60;
    graphview.topPadding = 10;
    graphview.yMin = 0;
    graphview.yMax = 300000000;
    graphview.touchEnabled = YES;
    graphview.valueFormat = @"%.0f";
    graphview.xAxisStyle.tickStyle.majorTicks = 8;
    graphview.legendType = Graph2DLegendTop;
    graphview.autoScaleMode = Graph2DAutoScaleMax;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = nil;
    graphview.displayNames = @{
                               @"PREVWIN":@"Skipped: Already Won",
                               @"SDT_USER":@"Skipped: No SDT User",
                               @"PUBLISHER":@"Skipped: Publisher",
                               @"WON" : @"Won",
                               @"TARGETED": @"Hourly Targeted Requests"
                               };
    //[graphview invalidateCache];
    graphview.cacheTTL = 3600;
    [graphview reload];
}

@end
