//
//  VolumnView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/23/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "VolumnView.h"
@interface VolumnView()<Graph2DDataSource, Graph2DChartDelegate>
{
    int count;
}
@end;

@implementation VolumnView

- (void) initChart
{
    [super initChart];
    count = 20;
    self.dataSource = self;
    self.chartDelegate = self;
    self.topPadding = 5;
    self.topMargin = self.bottomMargin = 5.0;
    self.barGap = 4;
    self.leftMargin = 30;
    self.drawXGrids = NO;
    self.drawYGrids = NO;
    self.touchEnabled = NO;
    self.barChartStyle = BarStyleCluster;
    self.fillStyle = nil;
    [self refresh];
}

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return count;
}

- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}

- (NSNumber *) graph2DView:(Graph2DView *)graph2DView valueAtIndex:(NSInteger)item forSeries:(NSInteger)series
{
    
    return  [NSNumber numberWithDouble: 0.5 + 0.4* cos(4 * item * M_PI/count + 2) ];
}
@end
