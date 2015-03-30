//
//  SSDataView.m
//  SixStreams
//
//  Created by Anping Wang on 1/31/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSDataView.h"
#import "DebugLogger.h"
#import "SSTimeSeries.h"

@interface SSDataView()
{
    NSMutableArray *charts;
    NSMutableArray *xLabels;
    NSMutableArray *xPoints;
    CGFloat offset;
    int xTicks;
    int maxCounts;
    int seriesCount;
    int points;
    int pointsInStep;
    float lastValue;
    int count;
}
@end

@implementation SSDataView

- (void) removeAll
{
    [charts removeAllObjects];
    count = 0;
    [self refresh];
}

- (void) removeSeries:(id) series
{

}

- (void) addSeries:(id) series
{
    count = [[series objectForKey:@"count"] intValue];
    SSTimeSeries *ts = [[SSTimeSeries alloc ] initWithDictionary:series];
    //DebugLog(@"%@", ts.dataPoints);
    title.text = ts.units;
    
    [charts addObject:series];
    
    
    title.hidden = charts.count != 1;
    [self refresh];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.dataSource = self;
    self.chartDelegate = self;
    self.view2DDelegate = self;
    self.autoScale = YES;
    
    self.topMargin = 25;
    self.topPadding = 10;
    self.bottomPadding = 0;
    self.bottomMargin = 80;
    self.leftMargin = 60;

    maxCounts = 356;
    pointsInStep = 1;
    xTicks = 11;
    offset = 1;
    
    charts = [NSMutableArray array];
    xLabels = [NSMutableArray array];
    xPoints = [NSMutableArray array];
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
    return [charts count];
}

//number of items in a group
//return number of items

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    id series = [charts objectAtIndex:graph];
    seriesCount = [series[@"count"] intValue];
    
    points = seriesCount > maxCounts ? maxCounts : seriesCount;
    
    NSArray *obsvs = series[@"observations"];
    
    [xPoints removeAllObjects];
    [xLabels removeAllObjects];
    
    for(int i = 0; i<points; i++)
    {
        long idx = [obsvs count] - points + i;
        if (idx >= 0)
        {
            id obvs = obsvs[idx];
            [xPoints addObject:obvs[@"date"]];
        }
    }
    
    for (int i = 0; i< xTicks; i++)
    {
        long idx = [obsvs count] - (int)points*(1.0 - i*1.0/(xTicks-1));
        if(idx < [obsvs count])
        {
            id obvs = obsvs[idx];
            [xLabels addObject:obvs[@"date"]];
        }
    }
    
    if(xLabels.count < xTicks)
    {
        [xLabels addObject:obsvs[obsvs.count -1][@"date"]];
    }
    
    return points;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(int)x
{
    if (x >= xLabels.count)
    {
        return @"";
    }
    return xLabels[x];
}


- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(int)y
{
    float scale = 10;
    
    if (self.yMax > 1000) {
        scale = 10000;
    }
    
    if (self.yMax > 1000000) {
        scale = 10000000;
    }
    
    
    if (self.yMax > 1000000000) {
        scale = 10000000000;
    }
    
    return [NSString stringWithFormat:@"%.1f %@", self.yMin + y * (self.yMax - self.yMin)/scale,
            scale == 10000 ? @"k" :
            (scale == 10000000 ? @"m" : (scale == 10000000000 ? @"b":@""))
             ];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    seriesStyle.color =  [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1];
    seriesStyle.gradient = NO;
    seriesStyle.lineStyle.penWidth = 1.0;
    seriesStyle.chartType = Graph2DLineChart;
    return seriesStyle;
}

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [[Graph2DAxisStyle alloc]init];
    xAxisStyle.tickStyle.majorTicks = xTicks;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.color = [UIColor blackColor];
    xAxisStyle.labelStyle.angle = -M_PI_4/2.0;
    xAxisStyle.tickStyle.penWidth = 1.0;
    xAxisStyle.tickStyle.majorLength = 5;
    xAxisStyle.labelStyle.offset = 0;
    xAxisStyle.tickStyle.color = [UIColor redColor];
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:10];
    return xAxisStyle;
}

- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *yAxisStyle = [[Graph2DAxisStyle alloc]init];
    yAxisStyle.tickStyle.majorTicks = 10;
    yAxisStyle.tickStyle.majorLength = 5;
    yAxisStyle.tickStyle.minorTicks = 1;
    yAxisStyle.hidden = NO;
    
    yAxisStyle.labelStyle.angle = -M_PI_4/2.0;
    yAxisStyle.color = [UIColor blackColor];
    yAxisStyle.labelStyle.offset = -10;
    yAxisStyle.tickStyle.color = [UIColor redColor];
    yAxisStyle.tickStyle.penWidth = 1.0;
    yAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:10];
    return yAxisStyle;
}

- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    Graph2DLineStyle *lineStyle = [[Graph2DLineStyle alloc]init];
    lineStyle.color = [UIColor redColor];
    lineStyle.penWidth = 1.0;
    lineStyle.lineType = LineStyleSolid;
    return lineStyle;
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    id observation = [charts objectAtIndex:series];
    NSArray *obsvs = [observation objectForKey:@"observations"];
    
    NSString *date = xPoints[index];
    for (long i = obsvs.count - 1; i >= 0 ; i--)
    {
        id obs = obsvs[i];
        if ([date isEqualToString:obs[@"date"]])
        {
            float value = lastValue;
            //DebugLog(@"%ld %ld %f", obsvs.count, obsvs.count - points +  index, value);
            if (obs[@"value"])
            {
                value = [obs[@"value"] floatValue];
                if (value == 0)
                {
                    value=lastValue;
                }
            }
            else
            {
                value = lastValue;
            }
            lastValue = value;
            return [NSNumber numberWithFloat:value];
        }
    }
    return [NSNumber numberWithFloat:0.0];
}

@end