//
//  SamplePieChart.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "SamplePieChart.h"
@interface SamplePieChart()
{
    BOOL stopped;
    CGFloat angle;
    NSArray *data;
}

@end

@implementation SamplePieChart


- (void) initChart
{
    [super initChart];
    
    self.chartType = Graph2DPieChart;
    self.dataSource = self;
    self.view2DDelegate = self;
    data = [[NSArray alloc] initWithObjects: @"1", @"2", @"3", @"4", @"5", @"6", nil];
    
    self.topPadding = self.bottomPadding = self.leftPadding = self.rightPadding = 30;
    self.drawBorder = YES;
    self.pieChartDelegate = self;
    stopped = YES;
    angle = 2*M_PI - 1;
    self.fillStyle = [[Graph2DFillStyle alloc]init];
    self.fillStyle.direction = Graph2DFillTopBottom;
    [self refresh];
}

- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    Graph2DLineStyle *lineStyle = [[Graph2DLineStyle alloc]init];
    lineStyle.color = [UIColor redColor];
    lineStyle.width = 1.0;

    lineStyle.lineType = LineStyleDash;
    return lineStyle;
}


- (Graph2DAxisStyle *) labelStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *xAxisStyle = [[Graph2DAxisStyle alloc]init];
    xAxisStyle.tickStyle.majorTicks = 5;
    xAxisStyle.tickStyle.minorTicks = 1;
    xAxisStyle.color = [UIColor whiteColor];
    xAxisStyle.labelStyle.offset = 30;
    xAxisStyle.labelStyle.hidden = NO;
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:12];
    return xAxisStyle;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView labelAt:(int)x
{
    return [NSString stringWithFormat:@"Pie %d", x];
}

- (CGFloat) startAngle:(Graph2DView *) graph2DView
{
    return angle;
}

- (IBAction)toggleAnimation:(id)sender
{
    stopped = !stopped;
    dispatch_queue_t testServer = dispatch_queue_create("Test-Server-Thread", NULL);
    dispatch_async(testServer, ^{
        while (!stopped)
        {
            angle += 0.1;
            if (angle > M_PI * 2)
            {
                angle = angle - M_PI * 2;
            }
            [NSThread sleepForTimeInterval:0.05];
            dispatch_async(dispatch_get_main_queue(),^ {
                [self setNeedsDisplay ];
            } );
            
        }
    });
}

- (UIColor *) graph2DView:(Graph2DView *)graph2DView colorForValue:(CGFloat)value atIndex:(int)index
{
    switch (index) {
        case 1:
            return [UIColor redColor];
            break;
        case 2:
            return [UIColor blueColor];
            break;
        case 3:
            return [UIColor greenColor];
            break;
            
        case 4:
            return [UIColor cyanColor];
            break;
        case 5:
            return [UIColor yellowColor];
            break;
        case 6:
            return [UIColor orangeColor];
            break;
        case 7:
            return [UIColor grayColor];
            break;
        default:
            break;
    }
    
    return [UIColor purpleColor];
}

- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    Graph2DSeriesStyle *lineStyle = [[Graph2DSeriesStyle alloc]init];
    lineStyle.color = [UIColor blueColor];
    lineStyle.gradient = YES;
    lineStyle.chartType = Graph2DPieChart;
    lineStyle.fillStyle.colorFrom = [UIColor blueColor];
    lineStyle.fillStyle.colorTo = [UIColor redColor];
    return lineStyle;
}

//number of items in a group
//return number of items
- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return [data count];
}
//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger)index forSeries:(NSInteger)series
{
    return [NSNumber numberWithFloat:[[data objectAtIndex:index] floatValue]];
}


@end
