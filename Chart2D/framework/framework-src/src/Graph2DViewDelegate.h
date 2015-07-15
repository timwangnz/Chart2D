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

@class Graph2DView;
@protocol Graph2DViewDelegate <NSObject>
@optional
- (Graph2DLineStyle *) borderLineStyle : (Graph2DView *) graph2DView;
@end

@protocol Graph2DChartDelegate<NSObject>
@optional
- (Graph2DSeriesStyle *) graph2DView : (Graph2DView *) graph2DView styleForSeries:(NSInteger) series;
- (Graph2DMarkerStyle *) graph2DSeries:(NSInteger)series markerAtIndex:(NSInteger)index;

- (Graph2DAxisStyle *) xAxisStyle : (Graph2DView *) graph2DView;
- (Graph2DAxisStyle *) yAxisStyle : (Graph2DView *) graph2DView;

//customize one point
- (Graph2DSeriesStyle *) graph2DView : (Graph2DView *) graph2DView styleForSeries:(NSInteger) series atIndex:(NSInteger)index;

- (NSString *) graph2DView : (Graph2DView *) graph2DView formatValue :(NSNumber *) value;

- (void) graph2DView:(Graph2DView *) graph2DView didSelectSeries:(NSInteger) series atIndex:(NSInteger) index;
@end

@protocol Graph2DPieDelegate<NSObject>
@required
- (Graph2DAxisStyle *) labelStyle : (Graph2DView *) graph2DView;
- (CGFloat) startAngle : (Graph2DView *) graph2DView;
- (UIColor *) graph2DView : (Graph2DView*) graph2DView colorForValue :(CGFloat) value atIndex: (NSInteger) index;
- (NSString *) graph2DView : (Graph2DView *) graph2DView labelAt :(NSInteger) x;
@optional
- (void) graph2DView:(Graph2DView *) graph2DView didSelectIndex:(NSInteger) index;
@end
