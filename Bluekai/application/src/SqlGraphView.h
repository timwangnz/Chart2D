//
//  SqlGraphView.h
//  BluekaiDemo
//
//  Created by Anping Wang on 5/11/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import <Chart2D/Chart2D.h>
#import "HTTPConnector.h"

@interface SqlGraphView : Graph2DChartView

@property NSString *title;
@property NSString *sql;
@property int limit;
@property NSMutableArray *valueFields;
@property NSString *xLabelField;

@property int cacheTTL;

- (void) reload;
- (void) invalidateCache;
@end
