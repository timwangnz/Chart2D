//
//  SSAnimiate.m
//  SixStreams
//
//  Created by Anping Wang on 2/9/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSAnimiate.h"

@interface SSAnimiate()
{
    float direction;
    NSTimer *timer;
    SSShape *shape;
    float step;
    UIDynamicAnimator *animator;
    UIGravityBehavior *gravity;
}
@end

@implementation SSAnimiate

- (void) start
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30 target:self
                                           selector:@selector(animate)
                                           userInfo:nil repeats:YES];
}
- (void) stop
{
    [timer invalidate];
}

- (void) bounce:(SSShape *)aShape
{
    direction = 1;
    step = 1;
    shape = aShape;
    if (animator == nil)
    {
        animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    [animator removeAllBehaviors];
    gravity = [[UIGravityBehavior alloc] initWithItems:@[aShape]];
 
    [animator addBehavior:gravity];
}

-(void) animate
{
    if (shape.start.y < 0) {
        direction = -direction;
    }
    
    if (shape.start.y > self.view.frame.size.height)
    {
        direction = -direction;
    }
    
    shape.start = CGPointMake(shape.start.x, shape.start.y + direction*step);
    shape.end = CGPointMake(shape.end.x, shape.end.y + direction*step);
    [self.view setNeedsLayout];
}

@end
