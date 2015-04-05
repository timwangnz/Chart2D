//
//  SSDataView.h
//  SixStreams
//
//  Created by Anping Wang on 1/31/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import <Chart2D/Chart2D.h>

@interface SSDataView : Graph2DChartView<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>
{
    IBOutlet UILabel *title;
}


- (void) removeAll;
- (void) addSeries:(id) series;
- (void) removeSeries:(id) series;
- (NSUInteger) numberOfSeries;
@end
