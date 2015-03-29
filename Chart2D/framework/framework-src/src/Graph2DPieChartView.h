//
//  Graph2DPieChartView.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import "Graph2DView.h"

@interface Graph2DPieChartView : Graph2DView

//UI delegate for pie chart
@property (strong, nonatomic) id<Graph2DPieDelegate> pieChartDelegate;
@property (nonatomic) CGFloat startAngle;

@end
