//
//  Graph2DArea.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import "Graph2DArea.h"


@interface Graph2DArea()
{
    CGRect _rect;
    CGFloat _startAngle;
    CGFloat _endAngle;
    CGFloat _radius;
    CGPoint _center;
    BOOL isRect;
}

@end
@implementation Graph2DArea

-(id)initWithRadius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle center:(CGPoint) center
{
    self = [super init];
    if (self)
    {
        _radius = radius;
        _startAngle = startAngle;
        _endAngle = endAngle;
        _center = center;
        isRect = NO;
    }
    return self;
}

-(id)initWithRect:(CGRect) aRect
{
    self = [super init];
    if (self)
    {
        _rect = aRect;
        isRect = YES;
    }
    return self;
}

- (BOOL) isInArea:(CGPoint )point
{
    if (isRect)
    {
        return CGRectContainsPoint(_rect, point);
    }
    else
    {
        CGFloat distance = sqrt(pow((_center.x - point.x), 2.0) + pow((_center.y - point.y), 2.0));
        if (distance> _radius)
        {
            return NO;
        }
        
        float angle = atan2( (point.y - _center.y), (point.x - _center.x));
        if (angle < 0)
        {
            angle = M_PI * 2 + angle;
        }
        
        if (angle > _startAngle && angle < _endAngle)
        {
            return YES;
        }
        angle = angle + 2 * M_PI;
        if (angle > _startAngle && angle < _endAngle)
        {
            return YES;
        }
        angle = angle + 4 * M_PI;
        if (angle > _startAngle && angle < _endAngle)
        {
            return YES;
        }
        
        return NO;
    }
    return NO;
}

@end
