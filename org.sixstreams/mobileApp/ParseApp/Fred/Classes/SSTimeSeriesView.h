//
//  SSTimeSeriesView.h
//  SixStreams
//
//  Created by Anping Wang on 3/29/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Chart2D/Chart2D.h>


@class SSTimeSeriesView;
@class SSTimeSeries;

@protocol TimeSeriesViewDelegate <NSObject>
- (void) timeSeriesView:(SSTimeSeriesView *) graph2DView didSelectSeries:(int) series atIndex:(int) index;
@end


@interface SSTimeSeriesView : Graph2DChartView<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>


@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic, retain) SSTimeSeries *selected;

@property BOOL excluedeWeekends;
@property BOOL showGrowthRate;
@property NSInteger pointsInView;
@property (nonatomic, retain) NSString *frequency;
@property (nonatomic) id<TimeSeriesViewDelegate> delegate;


- (void) removeAll;
- (void) addSeries:(id) series;
- (id) seriesAt:(int) series;
- (void) removeSeries:(id) series;
- (NSUInteger) numberOfSeries;
- (void) clearSelection;
- (void) setChartType:(int) type;

- (NSArray *) timeserieses;

- (void) updateUI;

@end
