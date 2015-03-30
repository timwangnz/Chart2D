//
//  Graph2DView.h
//  Anping Wang
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Graph2DDataSource.h"
#import "Graph2DViewDelegate.h"
#import "Graph2DSeriesStyle.h"
#import "Graph2DFillStyle.h"
#import "Graph2DGridStyle.h"

#define DEFAULT_FONT @"Helvetica"
#define DEFAULT_AXIS_GAP 10;

@interface Graph2DView : UIView
{
    CGRect gDrawingRect;
    CGRect gBounds;
    CGPoint gBottomLeft;
}

//data delegate
@property (strong, nonatomic) id<Graph2DDataSource> dataSource;
//UI delegate
@property (strong, nonatomic) id<Graph2DViewDelegate> view2DDelegate;

//how to fill the view
@property (strong, nonatomic) Graph2DFillStyle *fillStyle;
//this can be overridden at series level
//pie chart can only have one series
//horzontal bar chart can not mix with line chart

@property (nonatomic) Graph2DChartType chartType;

@property (nonatomic) BOOL drawBorder;

@property (nonatomic) CGFloat topMargin;
@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat rightMargin;
@property (nonatomic) CGFloat bottomMargin;

@property (nonatomic) CGFloat topPadding;
@property (nonatomic) CGFloat leftPadding;
@property (nonatomic) CGFloat rightPadding;
@property (nonatomic) CGFloat bottomPadding;

@property (nonatomic) Graph2DBorderStyle borderStyle;
@property (nonatomic) BOOL touchEnabled;

- (void) refresh;
- (CGRect) getGraphBounds;


- (void) initChart;

@end
