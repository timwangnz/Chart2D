//
//  SqlPieChartView.h
//  Bluekai
//
//  Created by Anping Wang on 6/7/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

#import <Chart2D/Chart2D.h>

@interface SqlPieChartView : Graph2DPieChartView

@property NSString *sql;

@property int cacheTTL;
@property int limit;
@property NSArray *valueFields;
- (void) reload;
- (void) invalidateCache;

@end
