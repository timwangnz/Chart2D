//
//  SamplePieChart.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import <Chart2D/Chart2D.h>

@interface SamplePieChart : Graph2DPieChartView<Graph2DPieDelegate, Graph2DDataSource, Graph2DViewDelegate>

- (IBAction)toggleAnimation:(id)sender;


@end
