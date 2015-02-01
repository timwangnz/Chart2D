//
//  WCMapTouchView.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCMapTouchView.h"


@interface WCMapTouchView ()

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation WCMapTouchView


@synthesize delegate = _delegate, callAtHitTest;


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView* returnMe = [super hitTest:point withEvent:event];
    if (![returnMe isKindOfClass:[UIButton class]] && self.callAtHitTest)
    {
        IMP imp = [self.delegate methodForSelector:self.callAtHitTest];
        void (*func)(id, SEL) = (void *)imp;
        func(self.delegate, self.callAtHitTest);
    }
    
    return returnMe;
}



@end
