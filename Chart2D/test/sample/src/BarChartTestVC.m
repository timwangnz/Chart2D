//
//  BarChartTestVC.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 7/8/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BarChartTestVC.h"
#import <Chart2D/Chart2D.h>

@interface BarChartTestVC ()<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>
{
    int count, waves, offset;
    NSMutableArray *values;
    IBOutlet Graph2DChartView *barchart2D;
}

@end

@implementation BarChartTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    barchart2D.topPadding = 10;
    barchart2D.barGap = 4;
    
    barchart2D.leftMargin = 100;
    barchart2D.bottomMargin = 130;
    
    barchart2D.drawXGrids = YES;
    barchart2D.drawYGrids = YES;
    
    barchart2D.barChartStyle = BarStyleCluster;
    barchart2D.chartType = Graph2DBarChart;

    barchart2D.fillStyle = nil;
    barchart2D.touchEnabled = YES;
    barchart2D.cursorType = Graph2DCursorCross;
    barchart2D.autoScaleMode = Graph2DAutoScaleMax;

    count = 20;
    waves = 1;
    offset = 2;

    barchart2D.dataSource = self;
    barchart2D.chartDelegate = self;
    barchart2D.view2DDelegate = self;

    [self setupData];
}

- (void) setupData
{
    values = [NSMutableArray arrayWithObjects:
              [NSMutableArray array],
              [NSMutableArray array],
              [NSMutableArray array],
              nil];
    
    for (int i = 0; i<count; i++) {
        CGFloat fRand = rand() * 3.0f /RAND_MAX ;
        NSNumber *value1  = [NSNumber numberWithDouble: 2.0+0.4 * sin(waves * i * M_PI/count * sin(offset)) + fRand];
        NSNumber *value2 = [NSNumber numberWithDouble: 4+1.5 * cos(waves * i * M_PI/count + offset)];
        [values[0] addObject:
         @{
           @"value" : value1,
           @"marker": [NSString stringWithFormat:@"Value %d", i],
           @"label2": [NSNumber numberWithInteger:i%2] ,
           @"label1": [NSNumber numberWithInteger:i%3],
           @"value2": value2
           }
         ];
    }
    [barchart2D refresh];
}

//graphs
//return 1 for one chart
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}

//number of items in a group
//return number of items
- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return count;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(NSInteger)x
{
    return [values[0] objectAtIndex:x][@"marker"];
}


- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(double) y
{
    return [NSString stringWithFormat:@"%.0f", y];
}

//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    return [values[series] objectAtIndex:index][@"value"];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(NSInteger) series
{
    Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    seriesStyle.chartType = Graph2DBarChart;
    seriesStyle.color =  [UIColor whiteColor];
    seriesStyle.gradient = YES;
    seriesStyle.lineStyle.width = 1.0;
    if (series==1)
    {
        seriesStyle.fillStyle.colorFrom = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        seriesStyle.fillStyle.colorTo = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    else{
        
        seriesStyle.fillStyle.colorFrom = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:0.5];
        seriesStyle.fillStyle.colorTo = [UIColor colorWithRed:0.2 green:0.8 blue:0.8 alpha:1.0];
    }
    seriesStyle.legend = [[Graph2DLegendStyle alloc]initWithText:@"Test" color:seriesStyle.color font:[UIFont systemFontOfSize:12]];
    
    return seriesStyle;
}

//how to draw border
- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    Graph2DLineStyle *lineStyle = [[Graph2DLineStyle alloc]init];
    lineStyle.color = [UIColor whiteColor];
    lineStyle.penWidth = 0.1;
    lineStyle.lineType = LineStyleSolid;
    return lineStyle;
}

//how to draw xaxis
- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [Graph2DAxisStyle defaultStyle];
    xAxisStyle.color = [UIColor whiteColor];
    xAxisStyle.penWidth = 0.1;
    xAxisStyle.lineType = LineStyleSolid;
    
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:20];
    xAxisStyle.labelStyle.offset = 5;
    xAxisStyle.tickStyle.majorTicks = count;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.tickStyle.penWidth = 0.1;
    xAxisStyle.tickStyle.majorLength = 7;
    xAxisStyle.tickStyle.minorLength = 4;
    xAxisStyle.labelStyle.angle = M_PI/2;
    xAxisStyle.tickStyle.showMinorTicks = YES;
    xAxisStyle.tickStyle.color = [UIColor whiteColor];
    xAxisStyle.labelStyle.color = [UIColor whiteColor];
    return xAxisStyle;
}

//how to draw y axis
- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *yAxisStyle = [Graph2DAxisStyle defaultStyle];
    
    yAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:20];
    yAxisStyle.penWidth = 0.1;
    yAxisStyle.lineType = LineStyleSolid;
    yAxisStyle.labelStyle.offset = 15;
    yAxisStyle.tickStyle.majorTicks = 6;
    yAxisStyle.tickStyle.penWidth = 0.1;
    yAxisStyle.tickStyle.majorLength = 7;
    yAxisStyle.tickStyle.minorLength = 4;
    yAxisStyle.labelStyle.hidden = NO;
    yAxisStyle.tickStyle.minorTicks = 1;
    yAxisStyle.tickStyle.showMinorTicks = YES;
    yAxisStyle.tickStyle.color = [UIColor greenColor];
    yAxisStyle.tickStyle.width = 1.0;
    return yAxisStyle;
}


@end
