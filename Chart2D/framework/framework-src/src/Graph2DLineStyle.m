//
//  Graph2DLineStyle.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DLineStyle.h"

@implementation Graph2DLineStyle

+ (Graph2DLineStyle *) borderStyle
{
    Graph2DLineStyle *borderStyle = [[Graph2DLineStyle alloc]init];
    borderStyle.color = [UIColor lightGrayColor];
    borderStyle.penWidth = 0.2;
    borderStyle.lineType = LineStyleSolid;
    return borderStyle;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _penWidth = 0.2;
        
    }
    return self;
}

@end
