//
//  Graph2DLineStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DStyle.h"

@interface Graph2DLineStyle : Graph2DStyle

@property (nonatomic) CGFloat penWidth;
@property (nonatomic) Graph2DLineType lineType;
@property (nonatomic) int width;
//return default border style
+ (Graph2DLineStyle *) borderStyle;


@end
