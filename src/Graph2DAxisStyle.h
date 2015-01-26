//
//  Graph2DAxisStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DLineStyle.h"
#import "Graph2DTickStyle.h"

@interface Graph2DAxisStyle : Graph2DLineStyle
@property CGFloat labelOffset;

@property (nonatomic, strong) UIFont * labelFont;

@property (nonatomic, strong) Graph2DTickStyle *tickStyle;

@property BOOL showLabel;
@property BOOL hidden;

@property CGFloat labelAngle;

@property (nonatomic, strong) NSString *labelFormat;

+ (Graph2DAxisStyle *) defaultStyle;

@end
