//
//  Graph2DTickStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/23/12.
//

#import "Graph2DLineStyle.h"

@interface Graph2DTickStyle : Graph2DLineStyle

@property NSInteger majorTicks;//grids
@property NSInteger minorTicks;
@property CGFloat majorLength;
@property CGFloat minorLength;
@property BOOL showMajorTicks;
@property BOOL showMinorTicks;

@end
