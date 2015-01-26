//
//  Graph2DTickStyle.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/23/12.
//

#import "Graph2DTickStyle.h"

@implementation Graph2DTickStyle

- (id) init
{
    self = [super init];
    if (self)
    {
        _majorLength = 5;
        _minorLength = 2;
        _showMajorTicks = YES;
        _showMinorTicks = NO;
        _minorTicks = 1;
        _minorTicks = 10;
    }
    return self;
}

@end
