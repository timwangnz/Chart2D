//
//  Sample2DView.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import <Chart2D/Chart2D.h>

@interface Sample2DView : Graph2DChartView<Graph2DDataSource, Graph2DChartDelegate, Graph2DViewDelegate>
{
    int count;
    int waves;
    CGFloat offset;
}

- (IBAction)toggleAnimation:(id)sender;
- (void) setupData;

@end
