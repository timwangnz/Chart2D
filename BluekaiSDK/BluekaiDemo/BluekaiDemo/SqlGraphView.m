//
//  SqlGraphView.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/11/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "SqlGraphView.h"

@interface SqlGraphView()<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>
{
    NSMutableArray *objects;
    NSMutableArray *filteredObjects;
    id dataReceived;
    IBOutlet UIActivityIndicatorView *activityView;
    
}

@end

@implementation SqlGraphView
- (void) drawRect:(CGRect)rect
{
    activityView.center = [self convertPoint:self.center fromView:self.superview];
    [super drawRect:rect];
}
- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        self.borderLineStyle = [[Graph2DLineStyle alloc]init];
        self.borderLineStyle.lineType = LineStyleSolid;
        self.borderLineStyle.color = [UIColor blackColor];
        self.borderLineStyle.penWidth = 1;
        
        self.valueFields = [NSMutableArray array];
        self.xAxisStyle = [[Graph2DAxisStyle alloc]init];
        self.xAxisStyle.tickStyle.majorTicks = 11;
        self.xAxisStyle.tickStyle.minorTicks = 1;
        self.xAxisStyle.color = [UIColor blackColor];
        self.xAxisStyle.labelStyle.angle = - M_PI_4/1.0;
        self.xAxisStyle.tickStyle.penWidth = 1.0;
        self.xAxisStyle.tickStyle.majorLength = 5;
        self.xAxisStyle.labelStyle.offset = 0;
        self.xAxisStyle.tickStyle.color = [UIColor blackColor];
        self.xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:10];
        self.yAxisStyle = [[Graph2DAxisStyle alloc]init];
        self.yAxisStyle.tickStyle.majorTicks = 6;
        self.yAxisStyle.tickStyle.majorLength = 5;
        self.yAxisStyle.tickStyle.minorTicks = 1;
        self.yAxisStyle.hidden = NO;
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.caption.text = self.title;
      self.caption.font = [UIFont systemFontOfSize:17];
        self.yAxisStyle.color = [UIColor blackColor];
        self.yAxisStyle.labelStyle.offset = -10;
        self.yAxisStyle.tickStyle.color = [UIColor blackColor];
        self.yAxisStyle.tickStyle.penWidth = 1.0;
        self.yAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        self.view2DDelegate = self;
    }
    return self;
}

- (void) reload
{
    HTTPConnector *conn = [[HTTPConnector alloc]init];
    self.dataSource = self;
    self.chartDelegate = self;
    self.chartType = Graph2DLineChart;
    conn.url = [NSString stringWithFormat: @"http://vulcan03.wdc.bluekai.com:8080/dataservice/api/v1/storage/query?limit=%d", self.limit <= 0 ? 500 : self.limit ];
    NSDictionary *sql = @{@"sql":self.sql};
    self.hidden = NO;
    [self addSubview:activityView];
    
   
    [activityView startAnimating];
    activityView.hidden = NO;
    [conn post: sql
    withHeader: @{@"Content-Type":@"application/json", @"x-bk-cdss-client-key":@"7CSnR44TTH6IPfGJSLyTaw"}
     onSuccess: ^(NSDictionary *data) {
         dataReceived = data;
         NSArray *pts = data[@"data"];
         [activityView removeFromSuperview];
         [activityView stopAnimating];
         if ([pts count] > 1)
         {
             objects = [NSMutableArray arrayWithArray:pts];
             filteredObjects = [NSMutableArray  arrayWithArray:pts];
             [self refresh];
              self.hidden = NO;
         }
         else{
             
         }
     }
     onFailure:^(NSError *error) {
         [activityView stopAnimating];
         [activityView removeFromSuperview];
     }
     ];
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(int) series
{
    Graph2DSeriesStyle *ss = [Graph2DSeriesStyle defaultStyle:Graph2DLineChart];
    ss.color = [UIColor redColor];
    if (series == 1)
    {
        ss.color = [UIColor blueColor];
    }
    if (series == 2)
    {
        ss.color = [UIColor greenColor];
    }
    if (series == 3)
    {
        ss.color = [UIColor brownColor];
    }
    ss.legend = self.valueFields[series];
    return ss;
}


- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    
    return self.xAxisStyle;
}

- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    return self.yAxisStyle;
}

- (Graph2DLineStyle *) borderStyle:(Graph2DView *)graph2DView
{
    return self.borderLineStyle;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(int)x
{
    if ([filteredObjects count] == 0)
    {
        return @"";
    }
    NSUInteger xAt = x * ([filteredObjects count] / (self.xAxisStyle.tickStyle.majorTicks  -1));
    if(xAt > [filteredObjects count] - 1)
    {
        xAt = [filteredObjects count] - 1;
    }
    id object = [filteredObjects objectAtIndex:xAt];
    return object[self.xLabelField];
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(int)y
{
    float scale = 1;
    
    if ((self.yMax - self.yMin) > 1000) {
        scale = 1000;
    }
    
    if ((self.yMax - self.yMin)  > 1000000) {
        scale = 1000000;
    }
    
    
    if ((self.yMax - self.yMin) > 1000000000) {
        scale = 1000000000;
    }
    
    float dy = (self.yMax - self.yMin) / 5;
    
    NSString *yLabel = [NSString stringWithFormat:@"%.1f %@", (self.yMin + y * dy)/scale,
            scale == 1000 ? @"k" :
            (scale == 1000000 ? @"m" : (scale == 1000000000 ? @"b":@""))
            ];
    //NSLog(@"%@ %f %f %d", yLabel, self.yMin, self.yMax, y);
    return yLabel;
}

- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return [self.valueFields count];
}

//number of items in a group
//return number of items
- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return [filteredObjects count];
}

//return value
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) item forSeries :(NSInteger) series
{
    id object = filteredObjects[item];
    id value = object[self.valueFields[series]];
    if ([value isKindOfClass:NSNumber.class])
    {
        return value;
    } else{
        NSNumber *number = [[[NSNumberFormatter alloc]init] numberFromString: value];
        return number;
    }
}

@end
