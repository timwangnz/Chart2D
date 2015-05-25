//
//  Graph2DAxisStyle.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DAxisStyle.h"

@implementation Graph2DLabelStyle

- (id) init
{
    self = [super init];
    if (self)
    {
        _offset = 1.0;
        _hidden = NO;
    }
    return self;
}

@end

@implementation Graph2DAxisStyle

+ (Graph2DAxisStyle *) defaultStyle
{
    return [[Graph2DAxisStyle alloc]init];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _tickStyle = [[Graph2DTickStyle alloc] init];
        _labelStyle = [[Graph2DLabelStyle alloc] init];
        _hidden = NO;
    }
    return self;
}

@end
