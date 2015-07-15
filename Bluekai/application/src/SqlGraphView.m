//
//  SqlGraphView.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/11/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "SqlGraphView.h"
#import "BKStorageManager.h"

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
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.caption.text = self.title;
        self.valueFields = [NSMutableArray array];
        self.cacheTTL = -1;
        self.drawXGrids = YES;
        self.drawYGrids = YES;

        self.view2DDelegate = self;
    }
    return self;
}

- (void) invalidateCache
{
    [BKStorageManager invalidateCache:self.sql];
}

- (BOOL) checkCache
{
    id cached = [BKStorageManager checkCache:self.sql timeToLive: self.cacheTTL];
    if (cached)
    {
        dataReceived = cached;
        NSArray *pts = dataReceived[@"data"];
        objects = [NSMutableArray arrayWithArray:pts];
        filteredObjects = [NSMutableArray  arrayWithArray:pts];
        [self refresh];
        self.hidden = NO;
        return YES;
    }
    return NO;
}

- (void) reload
{
    self.dataSource = self;
    self.chartDelegate = self;
    self.chartType = Graph2DLineChart;
    objects = nil;
    filteredObjects = nil;
    if (![self checkCache])
    {
        HTTPConnector *conn = [[HTTPConnector alloc]init];
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
             
             [BKStorageManager cacheData:data at:self.sql];
             [activityView removeFromSuperview];
             [activityView stopAnimating];
             if ([pts count] > 1)
             {
                 objects = [NSMutableArray arrayWithArray:pts];
                 filteredObjects = [NSMutableArray  arrayWithArray:pts];
                 [self refresh];
                 self.hidden = NO;
             }
         }
         onFailure:^(NSError *error) {
             [activityView stopAnimating];
             [activityView removeFromSuperview];
         }
         ];
    }
}

- (Graph2DSeriesStyle *) graph2DView:(Graph2DView *)graph2DView styleForSeries:(NSInteger) series
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
    
    if (series == 4)
    {
        ss.color = [UIColor yellowColor];
    }
    
    NSString *legend = self.valueFields[series];
    
    ss.gradient = YES;
    ss.lineStyle.penWidth = 1;
    if (self.displayNames)
    {
        legend = self.displayNames[legend];
    }
    
    ss.legend = [[Graph2DLegendStyle alloc]initWithText:legend color:ss.color font:[UIFont systemFontOfSize:10]];
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

- (NSString *) graph2DView:(Graph2DView *)graph2DView xLabelAt:(NSInteger)x
{
    if ([filteredObjects count] == 0)
    {
        return @"";
    }
    NSUInteger xAt = x * (1.0*[filteredObjects count] / (self.xAxisStyle.tickStyle.majorTicks  -1));
    if(xAt > [filteredObjects count] - 1)
    {
        xAt = [filteredObjects count] - 1;
    }
    id object = [filteredObjects objectAtIndex:xAt];
    return object[self.xLabelField];
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView yLabelAt:(NSInteger)y
{
    float dy = (self.yMax - self.yMin) / (self.yAxisStyle.tickStyle.majorTicks - 1);
    return [self graph2DView:self formatValue:[NSNumber numberWithFloat:self.yMin + y * dy]];
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView formatValue:(NSNumber *)value
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
    
    NSString *unit = scale == 1000 ? @"k" : (scale == 1000000 ? @"m" : (scale == 1000000000 ? @"b": @""));
    
    return [NSString stringWithFormat:@"%.1f %@", [value floatValue]/scale, unit];
}

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return [filteredObjects count];
}

//return value
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return [self.valueFields count];
}
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
