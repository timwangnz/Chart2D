//
//  Graph2DVC.m
//  Oracle Daas
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "Graph2DVC.h"
#import <Chart2D/Chart2D.h>

@interface Graph2DVC ()
{
    NSInteger selected;
    NSArray *data;
    CGRect restoreRect;
}
@property (strong, nonatomic) IBOutlet Graph2DChartView *graph2DView;

@end

@implementation Graph2DVC
- (IBAction) maximze:(id)sender
{
    UIButton *btn = sender;
    restoreRect = btn.superview.frame;
    btn.superview.frame = self.view.frame;
    [self.view bringSubviewToFront:btn.superview];
}

- (IBAction) restore:(id)sender
{
    UIButton *btn = sender;
    btn.superview.frame = restoreRect;
    
}
- (IBAction)changChartType:(id)sender
{
    self.graph2DView.chartType = chartType.selectedSegmentIndex;
    
    if (chartType.selectedSegmentIndex == Graph2DHorizontalBarChart) {
        self.graph2DView.rightPadding  =
        self.graph2DView.leftPadding  =
        self.graph2DView.topPadding  =
        self.graph2DView.bottomPadding = 0;
        
        self.graph2DView.rightPadding = 20;
        self.graph2DView.topPadding = 0;
        self.graph2DView.barGap = 2;
        self.graph2DView.fillStyle.direction = Graph2DFillBottomTop;
        self.graph2DView.fillStyle.colorFrom = [UIColor blackColor];
        self.graph2DView.fillStyle.colorTo = [UIColor redColor];

    } 
    else{
        self.graph2DView.rightPadding  =
        self.graph2DView.leftPadding  =
        self.graph2DView.topPadding  =
        self.graph2DView.bottomPadding = 0;
        
        self.graph2DView.rightPadding = 0;
        self.graph2DView.topPadding = 20;
        self.graph2DView.barGap = 5;
    
        self.graph2DView.fillStyle.direction = Graph2DFillBottomTop;
        self.graph2DView.fillStyle.colorFrom = [UIColor greenColor];
        self.graph2DView.fillStyle.colorTo = [UIColor redColor];
    }
}

- (NSString *) graph2DView:(Graph2DView *) graph2DView xLabelAt:(NSInteger)x
{
    return [NSString stringWithFormat:@"%ld", (long)x];
}


- (NSString *) graph2DView:(Graph2DView *) graph2DView yLabelAt:(double)y
{
    return [NSString stringWithFormat:@"%ld", (long)y];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    svGraphContainer.contentSize = CGSizeMake(
                self.graph2DView.frame.size.width, self.graph2DView.frame.size.height);
    
    data = [[NSArray alloc] initWithObjects: @"0.7", @"0.4", @"0.9", @"1.0", @"0.2", @"0.85",
                      @"-0.11", @"0.75", @"-0.53", @"0.44", @"-0.88", @"0.77", nil];
    self.graph2DView.dataSource = self;
    self.graph2DView.chartDelegate = self;
    self.graph2DView.topPadding = 20;
    self.graph2DView.barGap = 5;
    self.graph2DView.fillStyle = [[Graph2DFillStyle alloc]init];
    self.graph2DView.fillStyle.direction = Graph2DFillBottomTop;
    self.graph2DView.fillStyle.colorFrom = [UIColor greenColor];
    self.graph2DView.fillStyle.colorTo = [UIColor redColor];
    self.title = @"Graph 2D Demo";
    [self.graph2DView refresh];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor] ;
    
    
}

- (void)viewDidUnload {
    svGraphContainer = nil;
   
                                                         
    [self setGraph2DView:nil];
    [super viewDidUnload];
}

- (void) graph2DView :(Graph2DView *) graph2DView didSelectSeries:(NSInteger)series atIndex:(NSInteger)index
{
    selected = index;
}

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *style = [[Graph2DAxisStyle alloc]init];
    style.tickStyle.majorTicks = 5;
    style.color = [UIColor redColor];
    style.labelStyle.hidden = YES;
    return style;
}

- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *style = [[Graph2DAxisStyle alloc]init];
    return style;
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
    return [data count];
}
//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger)index forSeries:(NSInteger)series
{
    return [NSNumber numberWithFloat:[[data objectAtIndex:index] floatValue]];
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView lowValueAtIndex:(NSInteger)index forSeries:(NSInteger)series
{
    return [NSNumber numberWithFloat:[[data objectAtIndex:index] floatValue]/3.0];
}


@end
