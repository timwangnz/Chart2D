//
//  SSTimeSeriesView.m
//  SixStreams
//
//  Created by Anping Wang on 3/29/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSTimeSeriesView.h"
#import "DebugLogger.h"
#import "SSTimeSeries.h"
#import "SSTimeUtil.h"

@interface SSTimeSeriesView()
{
    NSMutableArray *charts;
    NSMutableArray *xLabels;
    NSMutableArray *xPoints;
    CGFloat offset;
    NSString *units;
    int xTicks;
    int maxCounts;
    NSUInteger seriesCount;
    NSUInteger points;
    int pointsInStep;
    float lastValue;
    int chartType;
    int count;
    int selected;
    IBOutlet UILabel *title;
}
@end

@implementation SSTimeSeriesView

- (NSUInteger) numberOfSeries
{
    return [charts count];
}
- (void) removeAll
{
    [charts removeAllObjects];
    count = 0;
    selected = -1;
    title.text = @"";
    [self refresh];
}

- (void) removeSeries:(id) series
{
    NSString *idStr = series[@"id"];
    for(SSTimeSeries *ts in charts)
    {
        if ([ts.id isEqualToString:idStr])
        {
            [charts removeObject:ts];
            break;
        }
    }
    [self refresh];
}

- (void) addSeries:(id) series
{
    count = [[series objectForKey:@"count"] intValue];
    SSTimeSeries *ts = [[SSTimeSeries alloc ] initWithDictionary:series];
    units = ts.units;
    title.text = @"";
    [charts addObject:ts];
    [self refresh];
}

- (void) setChartType:(int) type
{
    chartType = type;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.dataSource = self;
    self.chartDelegate = self;
    self.view2DDelegate = self;
    
    self.topMargin = 25;
    self.topPadding = 10;
    self.bottomPadding = 0;
    self.bottomMargin = 80;
    self.leftMargin = 60;
    
    self.touchEnabled = YES;
    self.cursorType = Graph2DCursorCross;
    
    maxCounts = 356;
    pointsInStep = 1;
    xTicks = 11;
    offset = 1;
    selected = -1;
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
    
    self.startDate = [SSTimeUtil dateAYearAgo : [NSDate date]];
    self.endDate = [NSDate date];
    self.frequency = @"D";
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
    SSTimeSeries *ts = [charts objectAtIndex:graph];
    seriesCount = [ts.dataPoints count];
    points = seriesCount > maxCounts ? maxCounts : seriesCount;
    
    NSArray *obsvs = ts.xPoints;
    [xPoints removeAllObjects];
    [xLabels removeAllObjects];
    
    for(int i = 0; i<points; i++)
    {
        long idx = [obsvs count] - points + i;
        if (idx >= 0)
        {
           [xPoints addObject:obsvs[idx]];
        }
    }

    for (int i = 0; i< xTicks; i++)
    {
        long idx = [obsvs count] - (int)points*(1.0 - i*1.0/(xTicks-1));
        if(idx < [obsvs count])
        {
            [xLabels addObject:obsvs[idx]];
        }
    }
    
    if(xLabels.count < xTicks)
    {
        [xLabels addObject:obsvs[obsvs.count -1]];
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
    
    if ((self.yMax - self.yMin) > 1000) {
        scale = 10000;
    }
    
    if ((self.yMax - self.yMin)  > 1000000) {
        scale = 10000000;
    }
    
    
    if ((self.yMax - self.yMin) > 1000000000) {
        scale = 10000000000;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", (self.yMin*10 + y * (self.yMax - self.yMin))/scale,
            scale == 10000 ? @"k" :
            (scale == 10000000 ? @"m" : (scale == 10000000000 ? @"b":@""))
            ];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    Graph2DSeriesStyle *seriesStyle = [[Graph2DSeriesStyle alloc]init];
    
    
    if (selected == -1)
    {
        seriesStyle.color =  [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:1];
    }
    else{
        if(selected == series)
        {
            seriesStyle.color =  [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:1];
        }
        else{
            seriesStyle.color =  [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.2];
        }
    }
    
    seriesStyle.chartType = Graph2DLineChart;
    seriesStyle.gradient = NO;
    seriesStyle.lineStyle.penWidth = 1.0;
    //seriesStyle.showMarker = YES;
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
    yAxisStyle.tickStyle.majorTicks = 11;
    yAxisStyle.tickStyle.majorLength = 5;
    yAxisStyle.tickStyle.minorTicks = 1;
    yAxisStyle.hidden = NO;
    
    yAxisStyle.labelStyle.angle = -M_PI_4/2.0;
    yAxisStyle.color = [UIColor blackColor];
    yAxisStyle.labelStyle.offset = -20;
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

- (void) graph2DView:(Graph2DView *)graph2DView didSelectSeries:(int)series atIndex:(int)index
{
    selected = series;
    if ([self.delegate respondsToSelector:@selector(timeSeriesView:didSelectSeries:atIndex:)])
    {
        [self.delegate timeSeriesView:self didSelectSeries:series atIndex:index];
    }
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    SSTimeSeries *ts = charts[series];
  
    return [ts growthRatioBetween:xPoints[0] and:xPoints[index]];
   // return [ts valueFor: xPoints[index]];
}

@end

