//
//  Vector.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/8/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "Vector.h"

@implementation Vector

-(CGFloat) getSimilarity:(Vector *) compareTo
{    
    CGFloat similarity = ([self getAngle] - [compareTo getAngle ]) ;
    similarity = sqrtf(similarity * similarity);
    //DebugLog(@"(%f, %f) - (%f, %f) %f %f %f %f", self.x, self.y, compareTo.x, compareTo.y, [self getAngle], [compareTo getAngle], [self distFrom:compareTo], similarity);
    return similarity;
}


- (CGFloat) distFrom:(Vector *) point;
{
    return sqrt((self.start.x-point.start.x)*(self.start.x-point.start.x) + (self.start.y-point.start.y)*(self.start.y-point.start.y));
}

- (CGFloat) length
{
    return sqrtf(self.x*self.x + self.y*self.y);
}

- (CGFloat) getAngle
{
    if (self.x > 0 && self.y>0)
    {
        return asinf(self.y / [self length]);
    }
    else if (self.x < 0 && self.y > 0)
    {
        return M_PI - asinf(self.y / [self length]);
    }
    else if (self.x < 0 && self.y < 0)
    {
        return M_PI + asinf(-self.y / [self length]);
    }
    else if (self.x >0 && self.y < 0)
    {
        return 2*M_PI - asinf(-self.y / [self length]);
    }
    else if (self.x == 0 && self.y > 0)
    {
        return M_PI_2;
    }
    else if (self.x == 0 && self.y < 0)
    {
        return 3*M_PI_2;
    }
    else if (self.x < 0 && self.y == 0)
    {
        return M_PI;
    }
    else if (self.x >0 && self.y == 0)
    {
        return 0;
    }
    else
    {
        return 0;
    }
}
@end
