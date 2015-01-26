//
//  Graph2DLineStyle.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/17/12.
//

#import "Graph2DSeriesStyle.h"

@implementation Graph2DSeriesStyle


+ (Graph2DSeriesStyle *) defaultStyle:(Graph2DChartType) chartType
{
    Graph2DSeriesStyle * seriesStyle = [[Graph2DSeriesStyle alloc]init];
    seriesStyle.chartType = chartType;
    seriesStyle.gradient = YES;
    seriesStyle.xAlign = Graph2DXAlignLeft;
    return seriesStyle;
}

+ (Graph2DSeriesStyle *) barStyleWithColor:(UIColor *) color
{
    Graph2DSeriesStyle * seriesStyle = [[Graph2DSeriesStyle alloc]init];
    seriesStyle.fillStyle.color = color;
    seriesStyle.gradient = YES;
    
    size_t numComponents = CGColorGetNumberOfComponents([color CGColor]);
    CGFloat newComponents[8] =
    {
        1.0, 0.5, 0.0, 0.2,
        1.0, 0.7, 0.0, 0.2
    };
    
    CGFloat w1=0.9,w2=0.93;
    const CGFloat *components = CGColorGetComponents([color CGColor]);
    if (numComponents == 4)
    {
        newComponents[0] = components[0]*w1;
        newComponents[1] = components[1]*w1;
        newComponents[2] = components[2]*w1;
        newComponents[3] = components[3];
        newComponents[4] = components[0]*w2;
        newComponents[5] = components[1]*w2;
        newComponents[6] = components[2]*w2;
        newComponents[7] = components[3];
    }
    else if(numComponents == 2)
    {
        newComponents[0] = components[0]*w1;
        newComponents[1] = components[0]*w1;
        newComponents[2] = components[0]*w1;
        newComponents[3] = components[1];
        newComponents[4] = components[0]*w2;
        newComponents[5] = components[0]*w2;
        newComponents[6] = components[0]*w2;
        newComponents[7] = components[1];
    }
    
    seriesStyle.fillStyle.colorFrom = [UIColor colorWithRed:newComponents[0] green:newComponents[1] blue:newComponents[2] alpha:newComponents[3]];
    seriesStyle.fillStyle.colorTo = [UIColor colorWithRed:newComponents[4] green:newComponents[5] blue:newComponents[6] alpha:newComponents[7]];
    return seriesStyle;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _lineStyle = [[Graph2DLineStyle alloc] init];
        _fillStyle = [[Graph2DFillStyle alloc] init];
        
    }
    return self;
}

@end
