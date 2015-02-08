//
//  SSSlideView.m
//  SixStreams
//
//  Created by Anping Wang on 7/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SSSlideView.h"

@interface SSSlideView ()
{
    CGPoint startPoint;
}

@end

@implementation SSSlideView


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    startPoint= [touch locationInView:self.superview];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    float dx = currentPoint.x - startPoint.x;
    [self.delegate view:self isMoving:dx/200];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    float dx = currentPoint.x - startPoint.x;
    [self.delegate view:self moveEnded:dx/200];
}

@end
