//
//  SSDataView.m
//  SixStreams
//
//  Created by Anping Wang on 1/31/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSDataView.h"

@implementation SSDataView

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [[Graph2DAxisStyle alloc]init];
    xAxisStyle.tickStyle.majorTicks = 10;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.color = [UIColor blackColor];
    xAxisStyle.labelStyle.angle = M_PI_4/0.7;
    xAxisStyle.tickStyle.penWidth = 1.0;
    xAxisStyle.tickStyle.majorLength = 5;
    xAxisStyle.labelStyle.offset = 0;
    xAxisStyle.labelStyle.color = [UIColor blueColor];
    xAxisStyle.tickStyle.color = [UIColor redColor];
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:6];
    return xAxisStyle;
}

- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *yAxisStyle = [[Graph2DAxisStyle alloc]init];
    yAxisStyle.tickStyle.majorTicks = 10;
    yAxisStyle.tickStyle.minorTicks = 1;
    yAxisStyle.hidden = NO;
    yAxisStyle.color = [UIColor whiteColor];
    yAxisStyle.labelStyle.offset = 5;
    yAxisStyle.tickStyle.color = [UIColor redColor];
    yAxisStyle.tickStyle.penWidth = 1.0;
    yAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:8];
    return yAxisStyle;
}

@end
