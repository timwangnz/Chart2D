//
//  Graph2DChartView.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import "Graph2DView.h"

enum
{
    Graph2DCursorRect                       = 2,
    Graph2DCursorCross                      = 1,
    Graph2DCursorNone                       = 0
};

typedef NSUInteger Graph2DCursorType;

@interface Graph2DChartView : Graph2DView

//delegate for this chart
@property (strong, nonatomic) id<Graph2DChartDelegate> chartDelegate;
//this determines how to draw the cursor when user touch and move within the chart
@property (nonatomic) Graph2DCursorType cursorType;

//indicating wether grid is drawn
@property (nonatomic) BOOL drawXGrids;
@property (nonatomic) BOOL drawYGrids;
//how to draw the grid
@property (strong, nonatomic) Graph2DGridStyle *gridStyle;

//this is the default chart style for all the series in the chart
//one can override this by changing the style from
//delegate call to get series style
//refer to Graph2DSeriesStyle
@property (nonatomic) Graph2DBarStyle barChartStyle;

//range for x coordinate
@property (nonatomic) CGFloat xFrom;
@property (nonatomic) CGFloat xTo;
//min and max value used to scale the chart.
//when autoscale flag is on, these values are calculated based on the data
//set
//if you want to manually control the scale, set these values and autoscale to NO
@property (nonatomic) CGFloat yMin;
@property (nonatomic) CGFloat yMax;

//This flag indicates if the chart should be automatically scaled based on data set
//default value is YES
@property (nonatomic) BOOL autoScale;

//gap between bars in a chart
@property (nonatomic) CGFloat barGap;


@end
