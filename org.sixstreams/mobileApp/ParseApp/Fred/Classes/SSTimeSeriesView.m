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
#import "SSJSONUtil.h"

@interface SSTimeSeriesView()
{
    NSMutableArray *charts;
    NSMutableArray *xLabels;
    
    NSMutableArray *xDates;
    NSMutableArray *xPoints;
    CGFloat offset;
    NSString *units;
    int xTicks;

    int pointsInStep;
    float lastValue;
    int chartType;
    
    IBOutlet UILabel *title;
}
@end

@implementation SSTimeSeriesView

- (NSArray *) timeserieses
{
    return charts;
}

- (void) clearSelection
{
    self.selected.selected = NO;
    self.selected = nil;
}

- (void) selectSeries:(NSInteger) series
{
    
}
- (NSUInteger) numberOfSeries
{
    return [charts count];
}

- (id) seriesAt:(int) series
{
    return [charts objectAtIndex:series];
}

- (void) removeAll
{
    [charts removeAllObjects];
    self.selected = nil;
    title.text = @"";
     [self updateModel];
    [self refresh];
}

- (void) removeSeries:(id) series
{
    NSString *idStr = series[@"id"];
    for(SSTimeSeries *ts in charts)
    {
        if ([ts.categoryId isEqualToString:idStr])
        {
            if (ts == self.selected)
            {
                self.selected = nil;
            }
            [charts removeObject:ts];
            break;
        }
    }
    [self updateModel];
    [self refresh];
}

- (void) addSeries:(id) series
{
    SSTimeSeries *ts = [[SSTimeSeries alloc ] initWithDictionary:series];
    units = ts.units;
    self.selected = nil;
    title.text = @"";
    
    ts.seriesStyle.color = [self color: [charts count] withAlpha:1.0];
    ts.seriesStyle.chartType = self.defaultStyle.chartType;
    ts.seriesStyle.barGap = self.defaultStyle.barGap;
    
    [charts addObject:ts];
    [self updateModel];
    [self refresh];
}

- (void) setChartType:(int) type
{
    chartType = type;
}

- (void) updateUI;
{
    [self updateModel];
    [self refresh];
}

- (void) updateModel
{
    [xPoints removeAllObjects];
    [xLabels removeAllObjects];
    if (charts.count == 0)
    {
        return;
    }
    
    [self updatePoints];
    for(NSString *date in xDates)
    {
        BOOL notFound = NO;
        for(int i = 0; i < charts.count;i++)
        {
            SSTimeSeries *ts = [charts objectAtIndex:i];
            NSArray *obsvs = ts.xPoints;
            
            if (![obsvs containsObject:date])
            {
                notFound = YES;
                break;
            }
        }
        if (!notFound)
        {
            [xPoints addObject:date];
        }
    }
    
    
    [xLabels removeAllObjects];
    
    NSUInteger points = xPoints.count;
    if (points > 0)
    {
        for (int i = 0; i< xTicks; i++)
        {
            long idx = points - (int)points*(1.0 - i*1.0/(xTicks-1));
            if(idx < points)
            {
                [xLabels addObject:xPoints[idx]];
            }
        }
        
        if(xLabels.count < xTicks)
        {
            [xLabels addObject:xPoints[points -1]];
        }
    }
    
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
    self.defaultStyle = [[Graph2DSeriesStyle alloc]init];
    self.defaultStyle.chartType = Graph2DLineChart;
    self.touchEnabled = YES;
    self.cursorType = Graph2DCursorCross;
    self.legendType = Graph2DLegendTop;
    
    pointsInStep = 1;
    xTicks = 11;
    offset = 1;
    self.selected = nil;
    self.pointsInView = 30;
    charts = [NSMutableArray array];
    xLabels = [NSMutableArray array];
    xPoints = [NSMutableArray array];
    
    self.gridStyle = [[Graph2DGridStyle alloc]init];
    self.gridStyle.lineType = LineStyleSolid;
    self.gridStyle.color =[UIColor grayColor];
    self.gridStyle.penWidth = 1;
    
    self.chartType = Graph2DLineChart;
    
    self.fillStyle = [[Graph2DFillStyle alloc]init];
    self.fillStyle.direction = Graph2DFillRightLeft;
    self.fillStyle.colorFrom = [UIColor blackColor];
    self.fillStyle.colorTo = [UIColor blackColor];
    
    self.frequency = @"D";
    
    [self updatePoints];
}


- (void) updatePoints
{
    
    if ([charts count] > 0)
    {
        xDates = [NSMutableArray array];
        self.endDate = [NSDate date];
        SSTimeSeries *ts = charts[0];
        //NSLog(@"%@", ts.xPoints);
        
        if ([ts.units isEqualToString:@"D"])
        {
            self.startDate = [SSTimeUtil days:- self.pointsInView from:self.endDate];
            
            NSDate *end = self.endDate;
            
            while ([end compare: self.startDate] == NSOrderedDescending) {
                [xDates insertObject:[SSTimeUtil stringFromDateWithFormat:@"yyyy-MM-dd" date:end] atIndex:0];
                end = [SSTimeUtil days:-1 from:end];
            }
        }
        else{
            xDates =  [NSMutableArray arrayWithArray:ts.xPoints];
        }
    }
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
    return [xPoints count];
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(int)x
{
    if (x >= xLabels.count)
    {
        return @"";
    }
    NSDate *date = xLabels[x];
    return [NSString stringWithFormat:@"%@", date];
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

- (UIColor *) color:(NSInteger) index withAlpha:(float) alpha
{
    switch (index) {
        case 0:
            return  [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:alpha];
        case 1:
            return  [UIColor colorWithRed:1 green:1.0 blue:0.0 alpha:alpha];
        case 2:
            return [UIColor colorWithRed:1 green:0.0 blue:1.0 alpha:alpha];
        case 3:
             return [UIColor colorWithRed:1 green:1.0 blue:1.0 alpha:alpha];
        case 4:
            return  [UIColor colorWithRed:0 green:1.0 blue:0.0 alpha:alpha];
        case 5:
            return [UIColor colorWithRed:0 green:1.0 blue:1.0 alpha:alpha];
        case 6:
            return [UIColor colorWithRed:0 green:0.0 blue:1.0 alpha:alpha];
        case 7:
            return [UIColor colorWithRed:1 green:0.0 blue:1.0 alpha:alpha];
        case 8:
            return [UIColor colorWithRed:1 green:0.5 blue:0.0 alpha:alpha];
        case 9:
            return [UIColor colorWithRed:1 green:0.0 blue:0.5 alpha:alpha];
        case 10:
            return [UIColor colorWithRed:0.5 green:0.0 blue:1.0 alpha:alpha];
        default:
           return  [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:alpha];
    }

}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    SSTimeSeries *ts = charts[series];
    if (self.selected)
    {
        if (ts != self.selected)
        {
            ts.seriesStyle.color = [self color:series withAlpha:0.2];
        }
        else
        {
            ts.seriesStyle.color = [self color:series withAlpha:1.0];
        }
    }
    else{
        ts.seriesStyle.color = [self color:series withAlpha:1.0];
    }
    ts.seriesStyle.legend.color = ts.seriesStyle.color;
    ts.seriesStyle.legend.text = [ts.title display:40 header:10] ;
    return ts.seriesStyle;
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
    
    //yAxisStyle.labelStyle.angle = -M_PI_4/2.0;
    yAxisStyle.color = [UIColor blackColor];
    yAxisStyle.labelStyle.offset = 10;
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
    if (series >= 0)
    {
        SSTimeSeries *ts = charts[series];
        if (self.selected != ts)
        {
            self.selected.selected = NO;
            
            self.selected = ts;
            self.selected.selected = YES;
            if ([self.delegate respondsToSelector:@selector(timeSeriesView:didSelectSeries:atIndex:)])
            {
                [self.delegate timeSeriesView:self didSelectSeries:series atIndex:index];
            }
            [self refresh];
        }
    } else if(self.selected)
    {
        [self clearSelection];
        [self refresh];
    }
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) index forSeries :(NSInteger) series
{
    SSTimeSeries *ts = charts[series];
    if (self.showGrowthRate) {
        return [ts growthRatioBetween:xPoints[0] and:xPoints[index]];
    }
    else
    {
        return [ts valueFor: xPoints[index]];
    }
}

@end

