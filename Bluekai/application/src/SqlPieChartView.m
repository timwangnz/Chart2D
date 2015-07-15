//
//  SqlPieChartView.m
//  Bluekai
//
//  Created by Anping Wang on 6/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

#import "SqlPieChartView.h"
#import "BKStorageManager.h"
#import "HTTPConnector.h"

@interface SqlPieChartView()<Graph2DDataSource, Graph2DPieDelegate, Graph2DViewDelegate>
{
    Graph2DAxisStyle *labelStyle;
    NSMutableArray *objects;
    NSMutableArray *filteredObjects;
    id dataReceived;
    float angle;
    
    IBOutlet UIActivityIndicatorView *activityView;
}
@end

@implementation SqlPieChartView

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
        self.cacheTTL = -1;
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.pieChartDelegate = self;
        self.dataSource = self;
        self.view2DDelegate = self;
        
    }
    return self;
}


- (void) initChart
{
    [super initChart];
    self.topPadding = self.bottomPadding = self.leftPadding = self.rightPadding = 10;
    self.drawBorder = NO;
    angle = 2*M_PI - 1;
    filteredObjects = [[NSMutableArray alloc] initWithObjects: @"1", @"2", @"3", @"4", @"5", @"6", nil];
    self.fillStyle = [[Graph2DFillStyle alloc]init];
    self.fillStyle.direction = Graph2DFillTopBottom;
    [self refresh];
}

- (CGFloat) startAngle:(Graph2DView *) graph2DView
{
    return angle;
}

- (Graph2DLineStyle *) borderLineStyle:(Graph2DView *)graph2DView
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
    xAxisStyle.color = [UIColor whiteColor];
    xAxisStyle.labelStyle.offset = 40;
    xAxisStyle.labelStyle.hidden = NO;
    xAxisStyle.labelStyle.font = [UIFont fontWithName:@"Helvetica" size:12];
    return xAxisStyle;
}

- (NSString *) graph2DView:(Graph2DView *)graph2DView labelAt:(NSInteger)x
{
    return self.displayNames[self.valueFields[x]];
}

- (UIColor *) graph2DView:(Graph2DView *)graph2DView colorForValue:(CGFloat)value atIndex:(NSInteger)index
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

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return [filteredObjects count];
}

//return value
- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}
- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger) item forSeries :(NSInteger) series
{
    return filteredObjects[item];
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
             if ([pts count] > 0)
             {
                 objects = [NSMutableArray arrayWithArray:pts];
                 id rowset = pts[0];
                 filteredObjects = [NSMutableArray array];
                 for (NSString *field in self.valueFields) {
                     [filteredObjects addObject:rowset[field]];
                 }
                 
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                     [self refresh];
                 }];
             }
         }
         onFailure:^(NSError *error) {
             [activityView stopAnimating];
             [activityView removeFromSuperview];
         }
         ];
    }
}
@end
