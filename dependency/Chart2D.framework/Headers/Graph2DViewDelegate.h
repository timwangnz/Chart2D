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
- (Graph2DLineStyle *) borderStyle : (Graph2DView *) graph2DView;
@end

@protocol Graph2DChartDelegate<NSObject>
@optional
- (Graph2DSeriesStyle *) graph2DView : (Graph2DView *) graph2DView styleForSeries:(int) series;
- (Graph2DAxisStyle *) xAxisStyle : (Graph2DView *) graph2DView;
- (Graph2DAxisStyle *) yAxisStyle : (Graph2DView *) graph2DView;

//customize one point
- (Graph2DSeriesStyle *) graph2DView : (Graph2DView *) graph2DView styleForSeries:(int) series atIndex:(int)index;
- (NSString *) graph2DView : (Graph2DView *) graph2DView xLabelAt :(int) x;
- (NSString *) graph2DView : (Graph2DView *) graph2DView yLabelAt :(int) y;

- (void) graph2DView:(Graph2DView *) graph2DView didSelectSeries:(int) series atIndex:(int) index;
@end

@protocol Graph2DPieDelegate<NSObject>
@required
- (Graph2DAxisStyle *) labelStyle : (Graph2DView *) graph2DView;
- (CGFloat) startAngle : (Graph2DView *) graph2DView;
- (UIColor *) graph2DView : (Graph2DView*) graph2DView colorForValue :(CGFloat) value atIndex: (int) index;
- (NSString *) graph2DView : (Graph2DView *) graph2DView labelAt :(int) x;
@optional
- (void) graph2DView:(Graph2DView *) graph2DView didSelectIndex:(int) index;
@end
