//
//  SSToolbarView.m
//  SixStreams
//
//  Created by Anping Wang on 2/15/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSToolbarView.h"

@implementation SSToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews) {
        if (CGRectContainsPoint(subview.frame, point)) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
    
}

@end
