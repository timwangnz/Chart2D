//
//  DeliveryGraphVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/21/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "DeliveryGraphVC.h"
#import "SqlGraphView.h"

@interface DeliveryGraphVC ()
{
    IBOutlet SqlGraphView *graphview;
}

@end

@implementation DeliveryGraphVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    graphview.sql = @"select to_char(start_time, 'MM/DD') TIME, sum(targeted) targeted, sum(LOSS_RECENCY) LOSS_RECENCY, sum(LOSS_BUYER_ONLY) BUYER_ONLY, sum(won) won from bk_delivery_view where start_time between sysdate - 7 and sysdate group by start_time order by start_time";
    graphview.limit = 150;
    graphview.title = self.title;
    graphview.valueFields[0] = @"TARGETED";
    graphview.valueFields[1] = @"WON";
    graphview.valueFields[2] = @"LOSS_RECENCY";
    graphview.valueFields[3] = @"BUYER_ONLY";
    graphview.xLabelField = @"TIME";
    
    graphview.topMargin = 25;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 60;
    graphview.topPadding = 10;
    graphview.yMin = 0;
    graphview.yMax = 300000000;
    
    graphview.xAxisStyle.tickStyle.majorTicks = 8;
    graphview.legendType = Graph2DLegendTop;
    graphview.autoScale = NO;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = nil;
    graphview.displayNames = @{
                               @"LOSS_RECENCY":@"Already Won",
                               @"BUYER_ONLY":@"Buyer Only",
                               @"WON" : @"Won",
                               @"TARGETED": @"Targed Profiles"
                               };
    //[graphview invalidateCache];
    [graphview reload];
}

@end
