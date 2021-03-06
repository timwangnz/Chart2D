//
//  Graph2DLineStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//

#import <Foundation/Foundation.h>
#import "Graph2DStyle.h"
#import "Graph2DLineStyle.h"
#import "Graph2DFillStyle.h"
#import "Graph2DMarkerStyle.h"
#import "Graph2DTextStyle.h"
#import "Graph2DLegendStyle.h"

enum
{
    Graph2DBarChart                       = 0,
    Graph2DHorizontalBarChart             = 2,
    Graph2DLineChart                      = 1,
    Graph2DPieChart                       = 3,
};
typedef NSInteger Graph2DChartType;

enum
{
    Graph2DXAlignLeft              = 0,
    Graph2DXAlignCenter             = 1,
};

typedef NSInteger Graph2DXAlign;

@interface Graph2DSeriesStyle : Graph2DStyle;

@property (nonatomic) BOOL gradient;
@property (nonatomic, strong) Graph2DLineStyle *lineStyle;
@property (nonatomic, strong) Graph2DFillStyle *fillStyle;
@property (nonatomic, strong) Graph2DMarkerStyle *markerStyle;

@property (nonatomic) Graph2DChartType chartType;
//whether this series is a range chart
//if yes, we will use lowValue method of data source
@property (nonatomic) BOOL isRangeChart;

//indicate if markers are showen for a series
@property (nonatomic) BOOL showMarker;
//these are values used to scale the series
@property (nonatomic) CGFloat maxValue;
@property (nonatomic) CGFloat minValue;

//specify the point location between x and x + 1
@property (nonatomic) Graph2DXAlign xAlign;//0 left, 1 middle

@property (nonatomic) Graph2DLegendStyle *legend;

@property CGFloat barGap;

+ (Graph2DSeriesStyle *) barStyleWithColor:(UIColor *) color;
+ (Graph2DSeriesStyle *) defaultStyle:(Graph2DChartType) chartType;

@end
