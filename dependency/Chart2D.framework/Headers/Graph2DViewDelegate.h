//
//  Graph2DViewDelegate.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//

#import <Foundation/Foundation.h>
#import "Graph2DSeriesStyle.h"
#import "Graph2DLineStyle.h"
#import "Graph2DAxisStyle.h"

@class Graph2DChartView;
@class Graph2DPieChartView;

@protocol Graph2DViewDelegate <NSObject>
@optional
- (Graph2DLineStyle *) borderLineStyle : (Graph2DView *) graph2DView;
@end

@protocol Graph2DChartDelegate<NSObject>
@optional
- (Graph2DSeriesStyle *) graph2DView : (Graph2DChartView *) graph2DView styleForSeries:(NSInteger) series;
- (Graph2DMarkerStyle *) graph2DSeries:(NSInteger)series markerAtIndex:(NSInteger)index;

- (Graph2DAxisStyle *) xAxisStyle : (Graph2DChartView *) graph2DView;
- (Graph2DAxisStyle *) yAxisStyle : (Graph2DChartView *) graph2DView;

//customize one point
- (Graph2DSeriesStyle *) graph2DView : (Graph2DChartView *) graph2DView styleForSeries:(NSInteger) series atIndex:(NSInteger)index;

- (NSString *) graph2DView : (Graph2DChartView *) graph2DView formatValue :(NSNumber *) value;

- (void) graph2DView:(Graph2DChartView *) graph2DView didSelectSeries:(NSInteger) series atIndex:(NSInteger) index;
@end

@protocol Graph2DPieDelegate<NSObject>
@required
- (Graph2DAxisStyle *) labelStyle : (Graph2DPieChartView *) graph2DView;
- (CGFloat) startAngle : (Graph2DPieChartView *) graph2DView;
- (UIColor *) graph2DView : (Graph2DPieChartView*) graph2DView colorForValue :(CGFloat) value atIndex: (NSInteger) index;
- (NSString *) graph2DView : (Graph2DPieChartView *) graph2DView labelAt :(NSInteger) x;
@optional
- (void) graph2DView:(Graph2DPieChartView *) graph2DView didSelectIndex:(NSInteger) index;
@end
