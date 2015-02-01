//
//  SSTimeSeriesView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 Oracle. All rights reserved.
//

#import "SSTimeSeriesView.h"


@interface SSTimeSeriesView ()
{
    
    NSMutableArray *values;
    NSMutableArray *xLabels;
    CGFloat offset;
    int xTicks;
    int maxCounts;
    int seriesCount;
    int points;
    int startAt;
    int pointsInStep;
    float lastValue;
    BOOL stopped;
    int count;
}


@end

@implementation SSTimeSeriesView

- (IBAction)startAnimate:(id)sender
{
    [self doAnimation];
}

-(void) doAnimation
{
    
    stopped = !stopped;
    dispatch_queue_t testServer = dispatch_queue_create("Test-Server-Thread", NULL);
    dispatch_async(testServer, ^{
        while (!stopped)
        {
            startAt -= pointsInStep;
            if(startAt < 0)
            {
                startAt = count - maxCounts;
                startAt = startAt < 0 ? 0 : startAt;
                stopped = YES;
            }
            [NSThread sleepForTimeInterval:0.05];
            dispatch_async(dispatch_get_main_queue(),^ {
                [self setNeedsDisplay ];
            } );
            
        }
        
        
    });
}

- (void) addSeries:(id) series
{
    [values removeAllObjects];
    count = [[series objectForKey:@"count"] intValue];
    startAt = count - maxCounts;
    startAt = startAt < 0 ? 0 : startAt;
    [values addObject:series];
    [self refresh];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.dataSource = self;
    self.chartDelegate = self;
    self.view2DDelegate = self;
    
    xTicks = 10;
    stopped = true;
    self.topMargin = 25;
    self.leftMargin = 40;
    self.topPadding = 10;
    self.bottomPadding = 1;
    
    maxCounts = 400;
    pointsInStep = 1;
    offset = 1;
    values = [NSMutableArray array];
    xLabels = [NSMutableArray array];
    self.gridStyle = [[Graph2DGridStyle alloc]init];
    self.gridStyle.lineType = LineStyleSolid;
    self.gridStyle.color =[UIColor grayColor];
    self.gridStyle.penWidth = 1;
    self.xFrom = 0;
    self.xTo = 1000;
    self.chartType = Graph2DLineChart;
    self.fillStyle = [[Graph2DFillStyle alloc]init];
    self.fillStyle.direction = Graph2DFillRightLeft;
}

//graphs
//return 1 for one chart
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return [values count];
}

//number of items in a group
//return number of items

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    id series = [values objectAtIndex:graph];
    seriesCount = [[series objectForKey:@"count"] intValue];
    
    points = seriesCount > maxCounts ? maxCounts : seriesCount;
   
    [xLabels removeAllObjects];
    
    NSArray *obsvs = [series objectForKey:@"observations"];
    
    for (int i = 0; i< xTicks; i++)
    {
        int idx = points*i/xTicks;
        if(startAt + idx < [obsvs count])
        {
            id obvs = [obsvs objectAtIndex:(startAt + idx)];
            [xLabels addObject:[obvs objectForKey:@"date"]];
        }
    }
    if(startAt + points - 1 < [obsvs count])
    {
        [xLabels addObject:[[obsvs objectAtIndex:(startAt + points - 1)] objectForKey:@"date"]];
    }
    return points;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(int)x
{
    id series = [values objectAtIndex:0];
    id def = [series objectForKey:@"seriesDef"];
    float scale = 1;
    
    if (self.yMax > 1000)
    {
        scale = 10000;
    }
    
    if (self.yMax > 1000000) {
        scale = 10000000;
    }
    
    
    if (self.yMax > 1000000000) {
        scale = 10000000000;
    }
    title.text = scale >1 ?
        [NSString stringWithFormat:@"%.0f %@", scale/10, [def objectForKey:@"units"]]
    :
    [NSString stringWithFormat:@"%@", [def objectForKey:@"units"]];
    return [xLabels objectAtIndex:x];
}


- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(int)y
{
    float scale = 10;
    if (self.yMax > 1000)
    {
        scale = 10000;
    }
    
    if (self.yMax > 1000000) {
        scale = 10000000;
    }

    
    if (self.yMax > 1000000000) {
        scale = 10000000000;
    }
    return [NSString stringWithFormat:@"%.2f", y * (self.yMax - self.yMin)/scale];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    if (series == 0)
    {
        seriesStyle.color =  [UIColor whiteColor];
        seriesStyle.gradient = YES;
        seriesStyle.lineStyle.penWidth = 1.0;
        seriesStyle.fillStyle.colorFrom = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        seriesStyle.fillStyle.colorTo = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        
        seriesStyle.chartType = Graph2DLineChart;
        return seriesStyle;
    }
    else if (series == 1)
    {
        seriesStyle.color =  [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1];
        seriesStyle.gradient = NO;
        seriesStyle.lineStyle.penWidth = 3.0;
        seriesStyle.chartType = Graph2DLineChart;
        
        return seriesStyle;
    }
    return nil;
}

- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    Graph2DLineStyle *lineStyle = [[Graph2DLineStyle alloc]init];
    lineStyle.color = [UIColor redColor];
    lineStyle.penWidth = 1.0;
    lineStyle.lineType = LineStyleSolid;
    return lineStyle;
}

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [[Graph2DAxisStyle alloc]init];
    xAxisStyle.tickStyle.majorTicks = xTicks;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.color = [UIColor blackColor];
    xAxisStyle.labelStyle.angle = M_PI_4;
    xAxisStyle.tickStyle.penWidth = 1.0;
    xAxisStyle.tickStyle.majorLength = 5;
    xAxisStyle.labelStyle.offset = 10;
    xAxisStyle.tickStyle.color = [UIColor redColor];
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:8];
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


//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    id observation = [values objectAtIndex:series];
    NSArray *obsvs = [observation objectForKey:@"observations"];
    if (points - index > 0)
    {
        id obs = [obsvs objectAtIndex:startAt + index];
        float value = [[obs objectForKey:@"value"] floatValue];
        
        if (value == 0)
        {
            value = lastValue;
        }
        
        lastValue = value;
        return [NSNumber numberWithFloat:value];
    }
    return [NSNumber numberWithFloat:0.0];
}


@end
