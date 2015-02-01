//
//  LinePoint.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import "SSLinePoint.h"

@implementation SSLinePoint

float nearBy(CGPoint p1, CGPoint p2, CGPoint p3)
{
    float a = area(p1, p2, p3);
    float d1= distance(p1, p2);
    
    if (d1 == 0)
    {
        d1 = 1;
    }
    
    double dist = 2*a/d1;
    
    if (dist < 6 && ((p3.x > fmin(p1.x, p2.x) && p3.x < fmax(p1.x, p2.x))||(p3.y > fmin(p1.y, p2.y) && p3.y < fmax(p1.y, p2.y))))
    {
        return YES;
    }
    return NO;
}

float distance(CGPoint p1, CGPoint p2)
{
    return sqrt((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
}

float area(CGPoint p1, CGPoint p2, CGPoint p3)
{
    float d1= distance(p3, p1);
    float d2=distance(p2, p1);
    float d3=distance(p3, p2);
    float s = (d1 + d2 +d3)/2;
    return sqrt(s*(s-d1)*(s-d2)*(s-d3));
}

- (SSLinePoint *) clone
{
    SSLinePoint *pt = [[SSLinePoint alloc]initWithPoint:self.pos];
    return pt;
}

- (id) initWithPoint:(CGPoint) point
{
    self = [super init];
    if (self)
    {
        self.pos = point;
    }
    return self;
}

- (id) initWithXnY:(NSArray *) array
{
    self = [self init];
    if (self)
    {
        self.pos =  CGPointMake([[array objectAtIndex:0]floatValue], [[array objectAtIndex:1] floatValue]);
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *) dic
{
    self = [self init];
    if (self)
    {
        self.pos =  CGPointMake([[dic objectForKey:@"x"]floatValue], [[dic objectForKey:@"y"]floatValue]);
    }
    return self;
}
- (NSString *) description
{
    return [NSString stringWithFormat:@"{x:%0.0f, y:%0.0f}", self.pos.x, self.pos.y];
}

- (NSString *) _toJson
{
    return [NSString stringWithFormat:@"{\"x\":%0.0f, \"y\":%0.0f}", self.pos.x, self.pos.y];
}

- (NSString *) toJson
{
    return [NSString stringWithFormat:@"%.0f,%.0f", self.pos.x, self.pos.y];
}

- (SSLinePoint *) add:(SSLinePoint *) point
{
    SSLinePoint * newPoint = [[SSLinePoint alloc]init];
    newPoint.pos = CGPointMake(self.pos.x + point.pos.x, self.pos.y + point.pos.y);
    return newPoint;
}



- (SSLinePoint *) mult:(CGFloat) scalor;
{
    SSLinePoint * newPoint = [[SSLinePoint alloc]init];
    newPoint.pos = CGPointMake(self.pos.x * scalor, self.pos.y * scalor);
    return newPoint;
}

- (CGFloat) distFrom:(CGPoint) point;
{
    return sqrt((self.pos.x-point.x)*(self.pos.x-point.x) + (self.pos.y-point.y)*(self.pos.y-point.y));
}

@end
