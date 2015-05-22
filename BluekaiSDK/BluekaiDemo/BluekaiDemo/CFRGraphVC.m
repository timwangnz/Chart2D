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

- (void)viewDidLoad {
    [super viewDidLoad];
   
    graphview.sql = @"select users_run, users_found, users_wasted, to_char(start_time, 'MM/DD HH24') TIME from bk_cfr_view where start_time between sysdate -1 and sysdate order by start_time";
    graphview.limit = 25;
    graphview.title = self.title;
    graphview.valueFields[0] = @"USERS_RUN";
    graphview.valueFields[1] = @"USERS_FOUND";
    graphview.valueFields[2] = @"USERS_WASTED";
    graphview.xLabelField = @"TIME";
    graphview.topMargin = 20;
    graphview.bottomMargin = 60;
    graphview.leftMargin = 70;
    graphview.topPadding = 10;
    graphview.yMin = 0;
        graphview.xAxisStyle.tickStyle.majorTicks = 12;
    graphview.chartType = Graph2DLineChart;
    graphview.fillStyle = [[Graph2DFillStyle alloc]init];
    graphview.fillStyle.color =[UIColor colorWithRed:0.1 green:0.2 blue:0.5 alpha:0.4];
    [graphview reload];
    
    
    tagged.sql = @"select total_tags,total_won, to_char(start_time, 'MM/DD HH24') TIME from bk_cfr_view where start_time between sysdate -1 and sysdate order by start_time";
    tagged.limit = 25;
    tagged.title = self.title;
    tagged.valueFields[0] = @"TOTAL_TAGS";
    tagged.valueFields[1] = @"TOTAL_WON";
    tagged.xLabelField = @"TIME";
    tagged.topMargin = 20;
    tagged.bottomMargin = 60;
    tagged.leftMargin = 70;
    tagged.topPadding = 10;
    tagged.yMin = 0;
    tagged.yMax = 2000000000;
    tagged.autoScale = NO;
        tagged.xAxisStyle.tickStyle.majorTicks = 12;
    tagged.chartType = Graph2DLineChart;
    tagged.fillStyle = [[Graph2DFillStyle alloc]init];
    tagged.fillStyle.color =[UIColor colorWithRed:0.7 green:0.2 blue:0.5 alpha:0.9];
    [tagged reload];

}

@end
