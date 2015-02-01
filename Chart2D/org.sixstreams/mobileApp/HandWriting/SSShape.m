//
//  Shape.m
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSShape.h"
#import "SSJSONUtil.h"
#import "ParseStorageHeader.h"
#import "SSGraph.h"
#import "SSDrawableView.h"

@implementation SSShape


- (id) init
{
    self = [super init];
    if (self)
    {
        self.penWidth = 5;
    }
    return self;
}

- (id) initWithData:(id) data
{
    return [self init];
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:self.graph.objectId forKey:@"graph"];
    
    NSMutableDictionary *selfData = [NSMutableDictionary dictionary];
    [selfData setObject:[self colorToString:self.color] forKey:@"c"];

    [selfData setObject:[NSString stringWithFormat:@"%.0f", self.penWidth] forKey:@"w"];
    [selfData setObject:[NSString stringWithFormat:@"%.0f", self.start.x] forKey:@"x1"];
    [selfData setObject:[NSString stringWithFormat:@"%.0f", self.end.x] forKey:@"x2"];
    [selfData setObject:[NSString stringWithFormat:@"%.0f", self.start.y] forKey:@"y1"];
    [selfData setObject:[NSString stringWithFormat:@"%.0f", self.end.y] forKey:@"y2"];
    [dic setObject:selfData forKey:@"data"];
    return dic;
}

- (void) updateModel
{
    //does nothing
}

- (CGRect) bounds
{
   return CGRectMake(fmin(self.start.x, self.end.x), fmin(self.start.y, self.end.y), fabs(self.end.x-self.start.x), fabs(self.end.y - self.start.y));
}

- (BOOL) collideWith:(SSShape *)shape
{
    return CGRectIntersectsRect(self.bounds, shape.bounds);
}

- (void) moveInX :(float) x andY:(float) y
{
    deltaX = x;
    deltaY = y;
    self.lastPos = CGPointMake(x, y);
    [self updateModel];
}

- (void) replay
{
    [self draw];
    [self.graph.inView redraw];
}

- (void) moveToX :(float) x andY:(float) y
{
    deltaX = 0;
    deltaY = 0;
    self.start = CGPointMake(self.start.x + x, self.start.y + y);
    self.end = CGPointMake(self.end.x + x, self.end.y + y);
    [self updateModel];
    self.graph.updated = YES;
}

- (BOOL) isPointOn:(CGPoint)point
{
    return NO;
}

- (BOOL) isIdenticalTo:(SSShape *)object
{
    return [[[object toDictionary]JSONString] isEqualToString: [[self toDictionary]JSONString]];
}

- (void) fromDictionary:(id) data
{
    [super fromDictionary:data];
    //self.objectId = [data objectForKey:REF_ID_NAME];
    NSDictionary *lineDic = [data objectForKey:@"data"];
    _penWidth = [[lineDic objectForKey:@"w"]floatValue];
    _end = CGPointMake([[lineDic objectForKey:@"x2"]floatValue], [[lineDic objectForKey:@"y2"]floatValue]);
    _start = CGPointMake([[lineDic objectForKey:@"x1"]floatValue], [[lineDic objectForKey:@"y1"]floatValue]);
    _color = [self stringToColor:[lineDic objectForKey:@"c"]];
}

- (void) reset
{
    //cleanup
}

- (void) draw
{

}

- (UIColor *) stringToColor:(NSString *) colorStr
{
    NSArray *components = [colorStr componentsSeparatedByString:@","];
    return [UIColor colorWithRed:[[components objectAtIndex:0]floatValue]
                           green:[[components objectAtIndex:1]floatValue]
                            blue:[[components objectAtIndex:2]floatValue]
                           alpha:[[components objectAtIndex:3]floatValue]];
}

- (NSString *) colorToString:(UIColor *) color
{
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f", components[0], components[1], components[2], components[3]];
}


- (NSString *) getEntityType
{
    return SHAPE_CLASS;
}

@end
