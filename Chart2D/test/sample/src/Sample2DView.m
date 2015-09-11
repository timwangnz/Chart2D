//
//  Sample2DView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "Sample2DView.h"
#import <Chart2D/Chart2D.h>

@interface Sample2DView ()
{
    BOOL stopped;
    NSMutableArray *values;
}

@end

@implementation Sample2DView

- (IBAction)toggleAnimation:(id)sender
{
    stopped = !stopped;
    dispatch_queue_t testServer = dispatch_queue_create("Test-Server-Thread", NULL);
    dispatch_async(testServer, ^{
        while (!stopped)
        {
            offset += 0.1;
            [self setupData];
            [NSThread sleepForTimeInterval:0.05];
            dispatch_async(dispatch_get_main_queue(),^ {
                [self setNeedsDisplay ];
            } );
            
        }
    });
}

//data
- (void) setupData
{
    values = [NSMutableArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
    
    for (int i = 0; i<count; i++) {
        CGFloat fRand = rand() * 0.1f /RAND_MAX ;
        [values[0] addObject:[NSNumber numberWithDouble: 0.4 * sin(waves * i * M_PI/count * sin(offset)) + fRand] ];
        [values[1] addObject:[NSNumber numberWithDouble: 1.5 * cos(waves * i * M_PI/count + offset)] ];
        [values[2] addObject:[NSNumber numberWithDouble: 1.5 + cos(waves * i * M_PI/count + offset)  + .3] ];
    }
    [self refresh];
}

- (void) initChart
{
    [super initChart];
    
    self.dataSource = self;
    self.chartDelegate = self;
    self.view2DDelegate = self;
    self.borderStyle = BorderStyle4Sides;
    count = 100;
    waves = 6;
    self.legendType = Graph2DLegendTop;
    self.topMargin = 45;
    self.topPadding = 10;
    self.bottomPadding = 1;
    self.touchEnabled = YES;
    
    stopped = YES;
    offset = 10;
    
    self.gridStyle = [[Graph2DGridStyle alloc]init];
    self.gridStyle.lineType = LineStyleSolid;
    self.gridStyle.color =[UIColor grayColor];
    self.gridStyle.width = 1;
    
    self.xFrom = 0;
    self.xTo = waves * M_PI;
    
    self.chartType = Graph2DLineChart;
    self.fillStyle = [[Graph2DFillStyle alloc]init];
    self.fillStyle.direction = Graph2DFillRightLeft;
    self.caption = [[Graph2DTextStyle alloc]initWithText:@"Test Caption"];
    self.caption.font = [UIFont systemFontOfSize:17];
    [self setupData];
    
}

//graphs
//return 1 for one chart
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 2;
}

//number of items in a group
//return number of items
- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return count;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(NSInteger)x
{
    return [NSString stringWithFormat:@"L %ld", (long)x];
}


- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(double)y
{
    return [NSString stringWithFormat:@"%ld", (long)y];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(NSInteger) series
{
    Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    if (series == 0)
    {
        seriesStyle.color =  [UIColor whiteColor];
        seriesStyle.gradient = YES;
        seriesStyle.lineStyle.width = 1.0;
        seriesStyle.fillStyle.colorFrom = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        seriesStyle.fillStyle.colorTo = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        seriesStyle.legend = [[Graph2DLegendStyle alloc]initWithText:@"Test" color:seriesStyle.color font:[UIFont systemFontOfSize:12]];
        seriesStyle.chartType = Graph2DLineChart;
        return seriesStyle;
    }
    else if (series == 1)
    {
        seriesStyle.color =  [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1];
        seriesStyle.gradient = NO;
        seriesStyle.lineStyle.width = 3.0;
        seriesStyle.chartType = Graph2DLineChart;
        seriesStyle.legend = [[Graph2DLegendStyle alloc]initWithText:@"Test Again" color:seriesStyle.color font:[UIFont systemFontOfSize:12]];
        return seriesStyle;
    }
    return nil;
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
    
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:8];
    xAxisStyle.labelStyle.offset = 5;
    xAxisStyle.tickStyle.majorTicks = 5;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.tickStyle.penWidth = 0.1;
    xAxisStyle.tickStyle.majorLength = 7;
    xAxisStyle.tickStyle.minorLength = 4;
    xAxisStyle.labelStyle.angle = M_PI_4;
    xAxisStyle.tickStyle.showMinorTicks = YES;
    xAxisStyle.tickStyle.color = [UIColor whiteColor];
    xAxisStyle.labelStyle.color = [UIColor whiteColor];
    return xAxisStyle;
}

//how to draw y axis
- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *yAxisStyle = [Graph2DAxisStyle defaultStyle];
    
    yAxisStyle.penWidth = 0.1;
    yAxisStyle.lineType = LineStyleSolid;
     yAxisStyle.labelStyle.offset = -15;
    yAxisStyle.tickStyle.majorTicks = 5;
     yAxisStyle.tickStyle.penWidth = 0.1;
    yAxisStyle.tickStyle.majorLength = 7;
    yAxisStyle.tickStyle.minorLength = 4;
    yAxisStyle.labelStyle.hidden = YES;
    yAxisStyle.tickStyle.minorTicks = 1;
    yAxisStyle.tickStyle.showMinorTicks = YES;
    yAxisStyle.tickStyle.color = [UIColor greenColor];
    
    yAxisStyle.tickStyle.width = 1.0;
    
    return yAxisStyle;
}


//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    return [values[series] objectAtIndex:index];
}


//sample
+ (u_int32_t)randomInRangeLo:(u_int32_t)loBound toHi:(u_int32_t)hiBound
{
    int32_t   range = hiBound - loBound + 1;
    return loBound + arc4random_uniform(range);
}

@end
