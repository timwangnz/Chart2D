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
    
    graphview.sql = @"select to_char(start_time, 'MM/DD HH24') TIME, sum(targeted) targeted, sum(won) won from bk_delivery_view where start_time between sysdate - 1 and sysdate group by start_time order by start_time";
    graphview.limit = 25;
    graphview.title = self.title;
    graphview.valueFields[0] = @"TARGETED";
    graphview.valueFields[1] = @"WON";
    graphview.xLabelField = @"TIME";
    graphview.topMargin = 25;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 60;
    graphview.topPadding = 10;
    graphview.yMin = 0;
    graphview.yMax = 300000000;
    graphview.xAxisStyle.tickStyle.majorTicks = 12;
    graphview.legendType = Graph2DLegendTop;
    graphview.autoScale = NO;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = nil;
  //  graphview.caption = [[Graph2DTextStyle alloc]initWithText:self.title];
  //  graphview.caption.font = [UIFont systemFontOfSize:17 weight:1];
  //  graphview.fillStyle.color =[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.4];
    [graphview reload];
}

@end
