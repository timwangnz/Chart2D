//
//  SSTimeSeriesView.h
//  SixStreams
//
//  Created by Anping Wang on 3/29/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Chart2D/Chart2D.h>

@interface SSTimeSeriesView : Graph2DChartView<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>

- (void) removeAll;
- (void) addSeries:(id) series;
- (void) removeSeries:(id) series;

@end
