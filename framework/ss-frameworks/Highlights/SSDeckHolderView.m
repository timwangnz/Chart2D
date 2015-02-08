//
//  SSDeckHolderView.m
//  SixStreams
//
//  Created by Anping Wang on 7/29/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSDeckHolderView.h"

@interface SSDeckHolderView()
{
    CGPoint startPoint;
    
    CGPoint superviewCenter;
    
    BOOL superviewCentered;
    float startY;
    BOOL isOpen;
}
@end

@implementation SSDeckHolderView
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    startPoint= [touch locationInView:self.superview];
    superviewCenter = self.superview.center;
    startY = self.frame.origin.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    float dy = currentPoint.y - startPoint.y;
    if ((dy > 0 && startY ==0) || (startY > 0 && dy < 0))
    {
        self.frame =  CGRectMake(0,  startY + dy, self.frame.size.width, self.frame.size.height);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    
    float dy = currentPoint.y - startPoint.y;
    if (dy > 0 && startPoint.y == 0)
        [self open];
    else{
        [self close];
    }
}
 */
- (void) toggleOpen
{
    if (!isOpen)
    {
        [self open];
    }
    else
    {
        [self close];
    }
    isOpen = !isOpen;
}
- (void) open
{
    [UIView animateWithDuration:0.5
                     animations:^{
        self.frame =  CGRectMake(0,  self.frame.size.height - 80, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void) close
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame =  CGRectMake(0,  0, self.frame.size.width, self.frame.size.height);
                     } completion:^(BOOL finished) {
                         
                     }];
}
@end
