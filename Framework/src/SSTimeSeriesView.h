//
//  SSTimeSeriesView.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Graph2DChartView.h"

@interface SSTimeSeriesView : Graph2DChartView<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>
{
    IBOutlet UILabel *title;
}

- (void) addSeries:(id) series;
- (IBAction)startAnimate:(id)sender;
@end
