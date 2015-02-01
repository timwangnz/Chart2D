//
//  BarChartView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "BarChartSampleView.h"

@implementation BarChartSampleView

- (void) initChart
{
    [super initChart];
    count = 40;
    self.xFrom = 0;
    waves = 4;
    self.xTo = waves*M_PI;
    self.topPadding = 10;
    self.barGap = 4;
    self.leftMargin = 30;
    self.drawXGrids = YES;
    self.drawYGrids = YES;
    self.barChartStyle = BarStyleCluster;
    self.chartType = Graph2DBarChart;
    self.fillStyle = nil;
    self.touchEnabled = YES;
    self.cursorType = Graph2DCursorCross;
    [self setupData];
}

//how many series
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 3;
}

//style for each series
- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int)series  
{
     Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    if (series == 0)
    {
        seriesStyle.color =  [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:0.8];
        seriesStyle.gradient = NO;
        seriesStyle.lineStyle.width = 1.0;
        seriesStyle.chartType = Graph2DLineChart;
        return seriesStyle;
    }
    else if (series == 1)
    {
        seriesStyle.color =  [UIColor colorWithRed:1.0 green:0.0 blue:0.3 alpha:0.8];
        seriesStyle.gradient = YES;
        seriesStyle.lineStyle.width = 2.0;
        seriesStyle.chartType = Graph2DBarChart;
        return seriesStyle;
    }
    else
    {
        seriesStyle.color = [UIColor greenColor];
        seriesStyle.lineStyle.width = 2.0;
        seriesStyle.fillStyle.color = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.4];
        seriesStyle.gradient = YES;
        seriesStyle.chartType = Graph2DLineChart;
        seriesStyle.xAlign =Graph2DXAlignCenter;
        return seriesStyle;
    }
}
//y axis style
- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *yAxisStyle = [Graph2DAxisStyle defaultStyle];
    yAxisStyle.tickStyle.majorTicks = 10;
    yAxisStyle.tickStyle.minorTicks = 1;
    
    yAxisStyle.color = [UIColor whiteColor];
    yAxisStyle.tickStyle.color = [UIColor whiteColor];
    
    yAxisStyle.width = 1;
    
    yAxisStyle.labelStyle.offset = 10;
    yAxisStyle.tickStyle.width = 1.0;
    //yAxisStyle.labelFont = [UIFont fontWithName:@"Helvetica" size:5];
    return yAxisStyle;
}

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [Graph2DAxisStyle defaultStyle];
    xAxisStyle.tickStyle.majorTicks = 10;
    xAxisStyle.tickStyle.minorTicks = 1;
   
    xAxisStyle.color = [UIColor whiteColor];
    xAxisStyle.width = 1;
   
    xAxisStyle.labelStyle.offset = 5;
    xAxisStyle.tickStyle.color = [UIColor whiteColor];
    xAxisStyle.tickStyle.width = 1.0;
    xAxisStyle.tickStyle.majorLength = 5;
 //   xAxisStyle.labelFont = [UIFont fontWithName:@"Helvetica" size:5];
    return xAxisStyle;
}

- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    Graph2DLineStyle *lineStyle = [[Graph2DLineStyle alloc]init];
    lineStyle.color = [UIColor grayColor];
    lineStyle.width = 1.0;
    lineStyle.lineType = LineStyleSolid;
    
    return lineStyle;
}
@end
